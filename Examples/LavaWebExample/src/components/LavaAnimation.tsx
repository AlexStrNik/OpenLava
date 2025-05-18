import React, { useEffect, useRef } from "react";
import { LavaRenderer } from "lava-web";

interface LavaAnimationProps {
  assetPath: string;
  width?: number;
  height?: number;
}

/**
 * A React component that wraps the LavaRenderer to display Lava animations.
 *
 * @param assetPath - Path to the Lava animation assets directory
 * @param width - Width of the animation canvas (default: 300)
 * @param height - Height of the animation canvas (default: 300)
 */
const LavaAnimation: React.FC<LavaAnimationProps> = ({
  assetPath,
  width = 300,
  height = 300,
}) => {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const rendererRef = useRef<LavaRenderer | null>(null);

  useEffect(() => {
    const initRenderer = async () => {
      if (!canvasRef.current) return;

      try {
        const renderer = new LavaRenderer(canvasRef.current);
        rendererRef.current = renderer;

        await renderer.loadLavaAsset(assetPath);

        renderer.play();
      } catch (err) {
        console.error("Error initializing Lava animation:", err);
      }
    };

    initRenderer();

    return () => {
      rendererRef.current = null;
    };
  }, [assetPath]);

  return (
    <canvas
      style={{ width, height }}
      ref={canvasRef}
      width={width * window.devicePixelRatio}
      height={height * window.devicePixelRatio}
    />
  );
};

export default LavaAnimation;
