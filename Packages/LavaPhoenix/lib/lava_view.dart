import 'package:flutter/material.dart';
import 'package:lava_phoenix/lava_controller.dart';
import 'package:lava_phoenix/lava_painter.dart';

/// A widget that displays a Lava animation.
///
/// This widget uses a [LavaController] to manage the animation state and
/// a [LavaPainter] to render the animation frames. It automatically updates
/// when the controller notifies of frame changes.
///
/// Example usage:
/// ```dart
/// final controller = LavaController();
/// await controller.loadLavaAsset('assets/animations/fire_loop');
/// controller.play();
///
/// // In your build method:
/// LavaView(controller: controller)
/// ```
class LavaView extends StatelessWidget {
  /// The controller that manages the animation state.
  ///
  /// This controller is responsible for loading the animation assets,
  /// controlling playback (play/pause), and tracking the current frame.
  final LavaController controller;

  /// Creates a new [LavaView] with the specified controller.
  ///
  /// The [controller] must not be null and should be properly initialized
  /// by loading an animation asset before this widget is rendered.
  const LavaView({super.key, required this.controller});

  /// Builds the widget tree for the Lava animation view.
  ///
  /// This method creates an [AnimatedBuilder] that listens to the controller
  /// for frame changes and updates the display accordingly. If no animation
  /// asset is loaded yet, it displays an empty [SizedBox].
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final asset = controller.asset;
        final frameIndex = controller.frameIndex;

        if (asset == null) {
          return const SizedBox();
        }

        return CustomPaint(
          painter: LavaPainter(
            asset: asset,
            frameIndex: frameIndex,
          ),
        );
      },
    );
  }
}
