import Metal
import MetalKit

public class LavaRenderer: NSObject, MTKViewDelegate {
  let device: MTLDevice

  private let loader: MTKTextureLoader
  private let commandQueue: MTLCommandQueue
  private let renderPipelineState: MTLRenderPipelineState

  private var outputTexture: MTLTexture?
  private var asset: LavaAsset?

  private var currentFrameIndex = 0
  private var lastFrameTime: CFTimeInterval = 0
  private var frameDuration: CFTimeInterval {
    guard let asset else { return 0 }

    return 1.0 / Double(asset.manifest.fps)
  }

  #if os(iOS) || os(tvOS)
    var displayLink: CADisplayLink?
  #elseif os(macOS)
    var displayLink: CVDisplayLink?
  #endif

  public override init() {
    self.device = MTLCreateSystemDefaultDevice()!
    self.loader = MTKTextureLoader(device: device)
    self.commandQueue = device.makeCommandQueue()!

    let descriptor = MTLRenderPipelineDescriptor()
    let library = makeLavaLibrary(device: device)
    descriptor.vertexFunction = library.makeFunction(name: "vertex_main")
    descriptor.fragmentFunction = library.makeFunction(name: "fragment_main")
    descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm_srgb

    self.renderPipelineState = try! device.makeRenderPipelineState(descriptor: descriptor)

    super.init()
  }

  public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
  }

  public func draw(in view: MTKView) {
    guard let asset, let outputTexture else { return }

    guard let drawable = view.currentDrawable,
      let commandBuffer = commandQueue.makeCommandBuffer(),
      let blitEncoder = commandBuffer.makeBlitCommandEncoder()
    else {
      return
    }

    renderFrame(
      outputTexture: outputTexture,
      blitEncoder: blitEncoder,
      asset: asset,
      frameIndex: currentFrameIndex
    )

    blitEncoder.endEncoding()

    guard let renderPassDesc = view.currentRenderPassDescriptor,
      let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDesc)
    else { return }

    let texAspect = Float(outputTexture.width) / Float(outputTexture.height)
    let viewAspect = Float(view.drawableSize.width) / Float(view.drawableSize.height)

    var scale = SIMD2<Float>(1, 1)
    if texAspect > viewAspect {
      scale.y = viewAspect / texAspect
    } else {
      scale.x = texAspect / viewAspect
    }

    renderEncoder.setRenderPipelineState(renderPipelineState)
    renderEncoder.setFragmentTexture(outputTexture, index: 0)
    renderEncoder.setVertexBytes(&scale, length: MemoryLayout<LavaUniforms>.stride, index: 0)
    renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
    renderEncoder.endEncoding()

    commandBuffer.present(drawable)
    commandBuffer.commit()
  }

  public func play() {
    guard let asset else { return }

    #if os(iOS) || os(tvOS)
      guard displayLink == nil else { return }

      let link = CADisplayLink(target: self, selector: #selector(step))
      link.preferredFramesPerSecond = asset.manifest.fps
      link.add(to: .main, forMode: .common)
      displayLink = link

    #elseif os(macOS)
      guard displayLink == nil else { return }

      var link: CVDisplayLink?
      CVDisplayLinkCreateWithActiveCGDisplays(&link)
      guard let cvLink = link else { return }

      CVDisplayLinkSetOutputCallback(
        cvLink,
        { _, inNow, _, _, _, userInfo in
          let mySelf = Unmanaged<LavaRenderer>.fromOpaque(userInfo!).takeUnretainedValue()

          let now = Double(inNow.pointee.videoTime) / Double(inNow.pointee.videoTimeScale)
          if now - mySelf.lastFrameTime >= mySelf.frameDuration {
            mySelf.lastFrameTime = now
            DispatchQueue.main.async {
              mySelf.step()
            }
          }
          return kCVReturnSuccess
        }, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))

      CVDisplayLinkStart(cvLink)
      displayLink = cvLink
    #endif
  }

  public func stop() {
    #if os(iOS) || os(tvOS)
      displayLink?.invalidate()
      displayLink = nil
    #elseif os(macOS)
      if let link = displayLink {
        CVDisplayLinkStop(link)
        displayLink = nil
      }
    #endif
  }

  @objc private func step() {
    guard let asset else { return }

    currentFrameIndex += 1
    if currentFrameIndex >= asset.manifest.frames.count {
      currentFrameIndex = 0
    }
  }

  private func renderFrame(
    outputTexture: MTLTexture,
    blitEncoder: MTLBlitCommandEncoder,
    asset: LavaAsset,
    frameIndex: Int,
  ) {
    let frame = asset.manifest.frames[frameIndex]

    if case .key(let keyFrame) = frame {
      blitEncoder.copy(
        from: asset.images[keyFrame.imageIndex],
        sourceSlice: 0,
        sourceLevel: 0,
        sourceOrigin: MTLOrigin(x: 0, y: 0, z: 0),
        sourceSize: MTLSize(
          width: asset.manifest.width,
          height: asset.manifest.height,
          depth: 1
        ),
        to: outputTexture,
        destinationSlice: 0,
        destinationLevel: 0,
        destinationOrigin: MTLOrigin(x: 0, y: 0, z: 0)
      )
    } else if case .diff(let lavaDiffFrame) = frame {
      for diff in lavaDiffFrame.diffs {
        let srcIndex = diff[0]
        let srcTileIndex = diff[1]
        let xCount = diff[2]
        let yCount = diff[3]
        let dstTileIndex = diff[4]

        let sourceTexture = asset.images[srcIndex]
        let cellSize = asset.manifest.cellSize

        let srcTilesPerRow = Int(ceil(Float(sourceTexture.width) / Float(cellSize)))
        let dstTilesPerRow = Int(ceil(Float(outputTexture.width) / Float(cellSize)))

        let srcX = (srcTileIndex % srcTilesPerRow) * cellSize
        let srcY = (srcTileIndex / srcTilesPerRow) * cellSize
        let dstX = (dstTileIndex % dstTilesPerRow) * cellSize
        let dstY = (dstTileIndex / dstTilesPerRow) * cellSize

        let copyWidth = min(
          min(xCount * cellSize, sourceTexture.width - srcX),
          outputTexture.width - dstX
        )
        let copyHeight = min(
          min(yCount * cellSize, sourceTexture.height - srcY),
          outputTexture.height - dstY
        )
        let size = MTLSize(
          width: copyWidth,
          height: copyHeight,
          depth: 1
        )

        blitEncoder.copy(
          from: sourceTexture,
          sourceSlice: 0,
          sourceLevel: 0,
          sourceOrigin: MTLOrigin(x: srcX, y: srcY, z: 0),
          sourceSize: size,
          to: outputTexture,
          destinationSlice: 0,
          destinationLevel: 0,
          destinationOrigin: MTLOrigin(x: dstX, y: dstY, z: 0)
        )
      }
    }
  }

  public func loadLavaAsset(assetURL: URL) throws {
    let manifestPath = assetURL.appendingPathComponent("manifest.json")

    let manifest = try JSONDecoder().decode(
      LavaManifest.self,
      from: try Data(contentsOf: manifestPath)
    )

    var images: [MTLTexture] = []
    for image in manifest.images {
      let imagePath = assetURL.appendingPathComponent(image.url)

      let imageTexture = try self.loader.newTexture(
        URL: imagePath
      )
      images.append(imageTexture)
    }

    self.asset = LavaAsset(
      images: images,
      manifest: manifest
    )

    let desc = MTLTextureDescriptor.texture2DDescriptor(
      pixelFormat: .bgra8Unorm_srgb,
      width: manifest.width,
      height: manifest.height,
      mipmapped: false
    )
    desc.usage = [.shaderRead, .shaderWrite]
    outputTexture = device.makeTexture(descriptor: desc)!
  }
}
