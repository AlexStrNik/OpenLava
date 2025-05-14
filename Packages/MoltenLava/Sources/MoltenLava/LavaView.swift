import Foundation
import MetalKit
import SwiftUI

#if os(iOS)
  public struct LavaView: UIViewRepresentable {
    let renderer: LavaRenderer

    public init(renderer: LavaRenderer) {
      self.renderer = renderer
    }

    public func updateUIView(_ uiView: MTKView, context: Context) {
    }

    public func makeUIView(context: Context) -> MTKView {
      let frame = CGRect(
        x: 0, y: 0, width: 300, height: 300
      )

      let view = MTKView(
        frame: frame, device: renderer.device
      )
      view.framebufferOnly = false
      view.delegate = context.coordinator
      view.preferredFramesPerSecond = 120
      view.clearColor = MTLClearColor.init(
        red: 0, green: 0, blue: 0, alpha: 0
      )

      view.colorPixelFormat = .bgra8Unorm_srgb

      view.layer.isOpaque = false
      view.isOpaque = false
      view.backgroundColor = .clear

      return view
    }

    public func makeCoordinator() -> LavaRenderer {
      return renderer
    }
  }
#elseif os(macOS)
  public struct LavaView: NSViewRepresentable {
    let renderer: LavaRenderer

    public init(renderer: LavaRenderer) {
      self.renderer = renderer
    }

    public func updateNSView(_ nsView: MTKView, context: Context) {
    }

    public func makeNSView(context: Context) -> MTKView {
      let frame = CGRect(
        x: 0, y: 0, width: 300, height: 300
      )

      let view = MTKView(
        frame: frame, device: renderer.device
      )
      view.framebufferOnly = false
      view.delegate = context.coordinator
      view.preferredFramesPerSecond = 120
      view.clearColor = MTLClearColor.init(
        red: 0, green: 0, blue: 0, alpha: 0
      )

      view.colorPixelFormat = .bgra8Unorm_srgb

      view.layer?.isOpaque = false

      return view
    }

    public func makeCoordinator() -> LavaRenderer {
      return renderer
    }
  }
#endif
