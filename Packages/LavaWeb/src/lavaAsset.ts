import { LavaManifest } from "./lavaManifest";

/**
 * Represents a loaded Lava animation asset ready for rendering.
 *
 * A LavaAsset contains all the data needed to render a Lava animation, including
 * the animation manifest with metadata and the WebGL textures for each frame.
 *
 * This interface is primarily used by the LavaRenderer class to manage and render
 * animation assets.
 */

export interface LavaAsset {
  manifest: LavaManifest;
  images: LavaAssetImage[];
}

export interface LavaAssetImage {
  texture: WebGLTexture;
  width: number;
  height: number;
}
