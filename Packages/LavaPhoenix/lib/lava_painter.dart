import 'package:flutter/material.dart';
import 'package:lava_phoenix/lava_asset.dart';

import 'lava_manifest.dart';

/// A custom painter that renders Lava animations frame by frame.
///
/// This painter handles the rendering of both keyframes and diff frames,
/// applying the appropriate transformations to display the animation
/// correctly within the available space.
///
/// Used internally by [LavaView] to render the animation.
class LavaPainter extends CustomPainter {
  /// The Lava animation asset to render.
  final LavaAsset asset;

  /// The current frame index to display.
  final int frameIndex;

  /// Creates a new [LavaPainter] with the specified asset and frame index.
  ///
  /// The [asset] contains the animation data and images.
  /// The [frameIndex] specifies which frame of the animation to render.
  LavaPainter({
    required this.asset,
    required this.frameIndex,
  });

  /// Paints the current frame of the Lava animation on the canvas.
  ///
  /// This method handles the rendering of both keyframes (complete images)
  /// and diff frames (partial updates) from the animation. It scales and
  /// positions the animation to fit within the available space while
  /// maintaining the aspect ratio.
  ///
  /// For keyframes, it simply draws the entire image. For diff frames,
  /// it applies each diff operation to update specific tiles in the frame.
  @override
  void paint(Canvas canvas, Size size) {
    final manifest = asset.manifest;
    final frame = manifest.frames[frameIndex];
    final paint = Paint();

    final contentWidth = manifest.width.toDouble();
    final contentHeight = manifest.height.toDouble();

    final scaleX = size.width / contentWidth;
    final scaleY = size.height / contentHeight;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final offsetX = (size.width - contentWidth * scale) / 2;
    final offsetY = (size.height - contentHeight * scale) / 2;

    canvas.save();
    canvas.translate(offsetX, offsetY);
    canvas.scale(scale);

    final cellSize = manifest.cellSize.toDouble();

    if (frame is LavaKeyFrame) {
      final image = asset.images[frame.imageIndex];
      canvas.drawImage(image, Offset.zero, paint);
    } else if (frame is LavaDiffFrame) {
      for (var entry in frame.diffs) {
        final srcIndex = entry[0];
        final srcTileIndex = entry[1];
        final countX = entry[2];
        final countY = entry[3];
        final destTileIndex = entry[4];

        final destTilesPerRow = (manifest.width / cellSize).ceil();
        final srcTilesPerRow = (asset.images[srcIndex].width / cellSize).ceil();

        final dstX = (destTileIndex % destTilesPerRow) * cellSize;
        final dstY = (destTileIndex ~/ destTilesPerRow) * cellSize;

        final srcX = (srcTileIndex % srcTilesPerRow) * cellSize;
        final srcY = (srcTileIndex ~/ srcTilesPerRow) * cellSize;

        final srcImage = asset.images[srcIndex];

        final srcRect = Rect.fromLTWH(
          srcX,
          srcY,
          countX * cellSize,
          countY * cellSize,
        );

        final dstRect = Rect.fromLTWH(
          dstX,
          dstY,
          countX * cellSize,
          countY * cellSize,
        );

        canvas.drawImageRect(srcImage, srcRect, dstRect, paint);
      }
    }

    canvas.restore();
  }

  /// Determines whether the painter should repaint.
  ///
  /// Returns true if the frame index or asset has changed, indicating
  /// that the animation needs to be redrawn.
  @override
  bool shouldRepaint(covariant LavaPainter oldDelegate) {
    return oldDelegate.frameIndex != frameIndex || oldDelegate.asset != asset;
  }
}
