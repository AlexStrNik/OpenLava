import { LavaAsset, LavaAssetImage } from "./lavaAsset";
import { LavaManifest } from "./lavaManifest";
import { createLavaProgram } from "./lavaShaders";

/**
 * Renders and controls Lava animations in a web environment using WebGL.
 *
 * The LavaRenderer is responsible for loading animation assets, managing playback state,
 * and rendering animation frames to a canvas element using WebGL.
 *
 * @example
 * ```typescript
 * // Create a renderer with a canvas element
 * const canvas = document.getElementById('animation-canvas') as HTMLCanvasElement;
 * const renderer = new LavaRenderer(canvas);
 *
 * // Load an animation asset
 * await renderer.loadLavaAsset('path/to/animation');
 *
 * // Start playing the animation
 * renderer.play();
 *
 * // Pause the animation when needed
 * renderer.pause();
 * ```
 */
export class LavaRenderer {
  #canvas: HTMLCanvasElement;
  #asset: LavaAsset | null = null;

  #gl: WebGLRenderingContext;
  #program: WebGLProgram | null = null;
  #renderTexture: WebGLTexture | null = null;
  #renderBuffer: WebGLRenderbuffer | null = null;

  #isPlaying = false;

  frameIndex = 1;

  /**
   * Creates a new LavaRenderer instance.
   *
   * @param canvas - The HTML canvas element to render the animation on.
   * The canvas should be properly sized and added to the DOM before creating the renderer.
   *
   * @throws Will throw an error if WebGL context cannot be obtained from the canvas.
   */
  constructor(canvas: HTMLCanvasElement) {
    this.#canvas = canvas;
    this.#gl = canvas.getContext("webgl")!;
    this.#program = createLavaProgram(this.#gl);
  }

  /**
   * Loads a Lava animation asset from the specified path.
   *
   * This method fetches the animation manifest and all required image resources,
   * then creates WebGL textures for rendering. The animation will be ready to play
   * once this method completes successfully.
   *
   * @param assetPath - Path to the directory containing the animation assets.
   *                   Must include a manifest.json file and all referenced image files.
   * @returns A promise that resolves when the asset is fully loaded.
   *
   * @example
   * ```typescript
   * await renderer.loadLavaAsset('assets/animations/fire_effect');
   * ```
   */
  async loadLavaAsset(assetPath: string) {
    const manifest: LavaManifest = await fetch(
      `${assetPath}/manifest.json`
    ).then((res) => res.json());

    const images = await Promise.all(
      manifest.images.map((image) => {
        return new Promise<HTMLImageElement>((resolve) => {
          const img = new Image();
          img.src = `${assetPath}/${image.url}`;
          img.onload = () => resolve(img);
        });
      })
    );

    const lavaImages: LavaAssetImage[] = [];

    for (const image of images) {
      const texture = this.#gl.createTexture()!;
      this.#gl.bindTexture(this.#gl.TEXTURE_2D, texture);
      this.#gl.pixelStorei(this.#gl.UNPACK_PREMULTIPLY_ALPHA_WEBGL, true);

      this.#gl.texImage2D(
        this.#gl.TEXTURE_2D,
        0,
        this.#gl.RGBA,
        this.#gl.RGBA,
        this.#gl.UNSIGNED_BYTE,
        image
      );
      this.#gl.texParameteri(
        this.#gl.TEXTURE_2D,
        this.#gl.TEXTURE_MIN_FILTER,
        this.#gl.LINEAR
      );
      this.#gl.texParameteri(
        this.#gl.TEXTURE_2D,
        this.#gl.TEXTURE_MAG_FILTER,
        this.#gl.LINEAR
      );
      this.#gl.texParameteri(
        this.#gl.TEXTURE_2D,
        this.#gl.TEXTURE_WRAP_S,
        this.#gl.CLAMP_TO_EDGE
      );
      this.#gl.texParameteri(
        this.#gl.TEXTURE_2D,
        this.#gl.TEXTURE_WRAP_T,
        this.#gl.CLAMP_TO_EDGE
      );
      this.#gl.bindTexture(this.#gl.TEXTURE_2D, null);

      lavaImages.push({
        texture,
        width: image.width,
        height: image.height,
      });
    }

    this.#asset = {
      manifest,
      images: lavaImages,
    };

    this.createRenderTexture(
      this.#asset.manifest.width,
      this.#asset.manifest.height
    );
  }

  /**
   * Starts playing the animation.
   *
   * Begins the animation playback from the current frame. The animation will
   * continue playing until pause() is called or the component is destroyed.
   *
   * If the animation is already playing or no asset is loaded, this method has no effect.
   *
   * @example
   * ```typescript
   * // Start playing the animation
   * renderer.play();
   * ```
   */
  play() {
    if (this.#isPlaying || !this.#asset) return;

    this.#isPlaying = true;
    this.startRenderLoop();
  }

  /**
   * Pauses the animation playback.
   *
   * Stops the animation playback while keeping the current frame displayed.
   * The animation can be resumed from this point by calling play().
   *
   * @example
   * ```typescript
   * // Pause the animation
   * renderer.pause();
   * ```
   */
  pause() {
    this.#isPlaying = false;
  }

  private startRenderLoop() {
    if (!this.#asset) {
      return;
    }

    let lastFrameTime = 0;
    const frameDuration = 1000 / this.#asset.manifest.fps;

    const animate = (timestamp: number) => {
      if (!this.#isPlaying || !this.#asset) return;

      const elapsed = timestamp - lastFrameTime;

      if (elapsed >= frameDuration) {
        lastFrameTime = timestamp - (elapsed % frameDuration);

        this.frameIndex =
          (this.frameIndex + 1) % this.#asset.manifest.frames.length;

        this.renderFrame();
      }

      requestAnimationFrame(animate);
    };

    requestAnimationFrame(animate);
  }

  /**
   * Renders the current frame of the animation to the canvas.
   * Handles both key frames and diff frames using WebGL.
   * @private
   */
  private renderFrame() {
    if (!this.#asset || !this.#program) {
      return;
    }

    const gl = this.#gl;

    gl.viewport(0, 0, this.#asset.manifest.width, this.#asset.manifest.height);

    gl.clearColor(0, 0, 0, 0);
    gl.clear(gl.COLOR_BUFFER_BIT);

    gl.bindFramebuffer(gl.FRAMEBUFFER, this.#renderBuffer);

    const frame = this.#asset.manifest.frames[this.frameIndex];
    if (frame.type === "key") {
      const image = this.#asset.images[this.frameIndex];
      this.drawImageRegion(image, 0, 0, 0, 0, image.width, image.height);
    } else if (frame.type === "diff") {
      for (const diff of frame.diffs) {
        const srcIndex = diff[0];
        const srcTileIndex = diff[1];
        const countX = diff[2];
        const countY = diff[3];
        const destTileIndex = diff[4];

        const srcImage = this.#asset.images[srcIndex];

        const cellSize = this.#asset.manifest.cellSize;

        const destTilesPerRow = Math.ceil(
          this.#asset.manifest.width / cellSize
        );
        const srcTilesPerRow = Math.ceil(
          this.#asset.images[srcIndex].width / cellSize
        );

        const dstX = (destTileIndex % destTilesPerRow) * cellSize;
        const dstY = Math.floor(destTileIndex / destTilesPerRow) * cellSize;

        const srcX = (srcTileIndex % srcTilesPerRow) * cellSize;
        const srcY = Math.floor(srcTileIndex / srcTilesPerRow) * cellSize;

        this.drawImageRegion(
          srcImage,
          srcX,
          srcY,
          dstX,
          dstY,
          countX * cellSize,
          countY * cellSize
        );
      }
    }

    this.drawRenderTexture();
  }

  /**
   * Draws a region of a texture onto the canvas with proper aspect ratio scaling
   *
   * @param image - The texture to draw from
   * @param srcX - X coordinate in the source texture to start copying from
   * @param srcY - Y coordinate in the source texture to start copying from
   * @param dstX - X coordinate in the destination canvas to draw to
   * @param dstY - Y coordinate in the destination canvas to draw to
   * @param width - Width of the region to copy from the source texture
   * @param height - Height of the region to copy from the source texture
   */
  private drawImageRegion(
    image: LavaAssetImage,
    srcX: number,
    srcY: number,
    dstX: number,
    dstY: number,
    width: number,
    height: number
  ) {
    if (!this.#program || !this.#asset) return;

    const gl = this.#gl;
    gl.useProgram(this.#program);

    const dstWidth = this.#asset.manifest.width;
    const dstHeight = this.#asset.manifest.height;

    let x1 = (dstX / dstWidth) * 2 - 1;
    let y1 = -((dstY / dstHeight) * 2 - 1);
    let x2 = ((dstX + width) / dstWidth) * 2 - 1;
    let y2 = -(((dstY + height) / dstHeight) * 2 - 1);

    const positions = new Float32Array([x1, y2, x2, y2, x1, y1, x2, y1]);

    const u1 = srcX / image.width;
    const v1 = srcY / image.height;
    const u2 = (srcX + width) / image.width;
    const v2 = (srcY + height) / image.height;

    const texCoords = new Float32Array([u1, v2, u2, v2, u1, v1, u2, v1]);

    const posLoc = gl.getAttribLocation(this.#program, "a_position");
    const texLoc = gl.getAttribLocation(this.#program, "a_texCoord");

    const posBuf = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, posBuf);
    gl.bufferData(gl.ARRAY_BUFFER, positions, gl.STATIC_DRAW);
    gl.enableVertexAttribArray(posLoc);
    gl.vertexAttribPointer(posLoc, 2, gl.FLOAT, false, 0, 0);

    const texBuf = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, texBuf);
    gl.bufferData(gl.ARRAY_BUFFER, texCoords, gl.STATIC_DRAW);
    gl.enableVertexAttribArray(texLoc);
    gl.vertexAttribPointer(texLoc, 2, gl.FLOAT, false, 0, 0);

    gl.activeTexture(gl.TEXTURE0);
    gl.bindTexture(gl.TEXTURE_2D, image.texture);
    gl.uniform1i(gl.getUniformLocation(this.#program, "u_texture"), 0);

    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);

    gl.deleteBuffer(posBuf);
    gl.deleteBuffer(texBuf);
  }

  private createRenderTexture(width: number, height: number) {
    const gl = this.#gl;

    this.#renderTexture = gl.createTexture()!;
    gl.bindTexture(gl.TEXTURE_2D, this.#renderTexture);
    gl.texImage2D(
      gl.TEXTURE_2D,
      0,
      gl.RGBA,
      width,
      height,
      0,
      gl.RGBA,
      gl.UNSIGNED_BYTE,
      null
    );
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);

    this.#renderBuffer = gl.createFramebuffer()!;
    gl.bindFramebuffer(gl.FRAMEBUFFER, this.#renderBuffer);
    gl.framebufferTexture2D(
      gl.FRAMEBUFFER,
      gl.COLOR_ATTACHMENT0,
      gl.TEXTURE_2D,
      this.#renderTexture,
      0
    );
  }

  private drawRenderTexture() {
    if (!this.#asset || !this.#program) return;

    const gl = this.#gl;
    const canvasWidth = this.#canvas.width;
    const canvasHeight = this.#canvas.height;

    gl.bindFramebuffer(gl.FRAMEBUFFER, null);

    gl.viewport(0, 0, canvasWidth, canvasHeight);
    gl.clearColor(0, 0, 0, 0);
    gl.clear(gl.COLOR_BUFFER_BIT);

    gl.useProgram(this.#program);

    const texWidth = this.#asset.manifest.width;
    const texHeight = this.#asset.manifest.height;

    const texAspect = texWidth / texHeight;
    const canvasAspect = canvasWidth / canvasHeight;

    let scaleX = 1;
    let scaleY = 1;
    if (texAspect > canvasAspect) {
      scaleY = canvasAspect / texAspect;
    } else {
      scaleX = texAspect / canvasAspect;
    }

    const positions = new Float32Array([
      -scaleX,
      -scaleY,
      scaleX,
      -scaleY,
      -scaleX,
      scaleY,
      scaleX,
      scaleY,
    ]);

    const texCoords = new Float32Array([0, 0, 1, 0, 0, 1, 1, 1]);

    const posLoc = gl.getAttribLocation(this.#program, "a_position");
    const texLoc = gl.getAttribLocation(this.#program, "a_texCoord");

    const posBuf = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, posBuf);
    gl.bufferData(gl.ARRAY_BUFFER, positions, gl.STATIC_DRAW);
    gl.enableVertexAttribArray(posLoc);
    gl.vertexAttribPointer(posLoc, 2, gl.FLOAT, false, 0, 0);

    const texBuf = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, texBuf);
    gl.bufferData(gl.ARRAY_BUFFER, texCoords, gl.STATIC_DRAW);
    gl.enableVertexAttribArray(texLoc);
    gl.vertexAttribPointer(texLoc, 2, gl.FLOAT, false, 0, 0);

    gl.activeTexture(gl.TEXTURE0);
    gl.bindTexture(gl.TEXTURE_2D, this.#renderTexture);
    gl.uniform1i(gl.getUniformLocation(this.#program, "u_texture"), 0);

    gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
  }
}
