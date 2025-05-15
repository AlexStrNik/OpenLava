import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lava_phoenix/lava_asset.dart';
import 'package:lava_phoenix/lava_manifest.dart';

/// Controls the loading and playback of Lava animations.
///
/// This controller is responsible for loading animation assets from the file system,
/// managing playback state, and controlling animation timing based on the
/// animation's frame rate.
///
/// Use this controller with [LavaView] to display the animation.
class LavaController extends ChangeNotifier {
  /// The loaded Lava animation asset, or null if not yet loaded.
  LavaAsset? asset;

  /// Whether the animation is currently playing.
  bool isPlaying = false;

  /// The current frame index being displayed.
  int frameIndex = 0;

  /// Internal timer used for animation playback.
  Timer? _timer;

  /// Loads a Lava animation from the specified asset path.
  ///
  /// The [assetPath] should point to a directory containing a manifest.json file
  /// and the required image atlas frames. This directory must be included in the
  /// pubspec.yaml assets section.
  ///
  /// Example:
  /// ```dart
  /// controller.loadLavaAsset('assets/animations/fire_loop');
  /// ```
  Future<void> loadLavaAsset(String assetPath) async {
    final manifestData = await rootBundle.loadString("$assetPath/manifest.json");
    final manifest = LavaManifest.fromJson(jsonDecode(manifestData));
    final images = <ui.Image>[];

    for (final image in manifest.images) {
      final imageData = await rootBundle.load("$assetPath/${image.url}");
      final codec = await ui.instantiateImageCodec(imageData.buffer.asUint8List());
      final frame = await codec.getNextFrame();

      images.add(frame.image);
    }

    asset = LavaAsset(
      images: images,
      manifest: manifest,
    );

    frameIndex = 0;
    notifyListeners();
  }

  /// Starts playing the animation.
  ///
  /// If the animation is already playing or no asset is loaded, this method
  /// has no effect. The playback speed is determined by the fps value in the
  /// animation manifest.
  void play() {
    if (isPlaying || asset == null) return;

    isPlaying = true;
    final frameDuration = Duration(milliseconds: (1000 / asset!.manifest.fps).round());

    _timer = Timer.periodic(frameDuration, (timer) {
      frameIndex = (frameIndex + 1) % asset!.manifest.frames.length;
      notifyListeners();
    });
  }

  /// Pauses the animation playback.
  ///
  /// The current frame remains displayed, and the animation can be resumed
  /// from this point by calling [play].
  void pause() {
    isPlaying = false;
    _timer?.cancel();
    _timer = null;
  }

  /// Disposes the controller and releases resources.
  ///
  /// This stops any ongoing animation and cleans up the timer.
  /// Always call this method when the controller is no longer needed.
  @override
  void dispose() {
    pause();
    super.dispose();
  }
}
