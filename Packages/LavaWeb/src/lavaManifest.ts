/**
 * Represents the version of the Lava animation format.
 * Currently only supports 'v1'.
 */
export type LavaVersion = "v1";

/**
 * Represents an image resource used in a Lava animation.
 *
 * Each image typically contains one or more animation frames or texture atlases
 * that will be used during rendering.
 */
export interface LavaImage {
  /** The URL or path to the image resource. */
  url: string;
}

/**
 * Represents a key frame in a Lava animation.
 *
 * A key frame is a complete frame that directly references an image in the
 * animation's image collection. These frames do not depend on previous frames.
 */
export interface LavaKeyFrame {
  /** Identifies this as a key frame. */
  type: "key";
  /** Index of the image in the animation's images array. */
  imageIndex: number;
}

/**
 * Represents a differential frame in a Lava animation.
 *
 * A diff frame contains changes relative to the previous frame, rather than
 * a complete image. This approach reduces file size and improves loading performance
 * for animations with minimal changes between frames.
 */
export interface LavaDiffFrame {
  /** Identifies this as a differential frame. */
  type: "diff";
  /** Array of differential data that describes changes from the previous frame. */
  diffs: number[][];
}

/**
 * Represents a frame in a Lava animation.
 *
 * A frame can be either a key frame (complete image) or a diff frame (changes from previous frame).
 * This union type allows the animation system to handle both frame types appropriately.
 */
export type LavaFrame = LavaKeyFrame | LavaDiffFrame;

/**
 * Represents the manifest for a Lava animation.
 *
 * The manifest contains all metadata and structural information needed to load and play
 * a Lava animation, including frame rate, dimensions, image resources, and frame data.
 *
 * This is the primary configuration object that defines a complete Lava animation.
 */
export interface LavaManifest {
  /** The version of the Lava animation format. */
  version: LavaVersion;
  /** Frames per second - controls animation playback speed. */
  fps: number;
  /** Size of each cell in the animation grid. */
  cellSize: number;
  /** Size of the differential image used for diff frames. */
  diffImageSize: number;
  /** Width of the animation in pixels. */
  width: number;
  /** Height of the animation in pixels. */
  height: number;
  /** Pixel density of the animation. */
  density: number;
  /** Whether the animation supports transparency. */
  alpha: boolean;
  /** Array of image resources used by the animation. */
  images: LavaImage[];
  /** Array of animation frames in sequence. */
  frames: LavaFrame[];
}
