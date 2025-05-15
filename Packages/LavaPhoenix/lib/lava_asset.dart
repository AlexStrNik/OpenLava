import 'dart:ui';

import 'package:lava_phoenix/lava_phoenix.dart';

/// A container for Lava animation assets.
/// 
/// Holds both the parsed manifest data and the loaded image atlas frames
/// needed for rendering the Lava animation.
class LavaAsset {
  /// The parsed manifest containing animation metadata and frame information.
  final LavaManifest manifest;
  
  /// The list of loaded image atlas frames referenced by the manifest.
  final List<Image> images;

  /// Creates a new [LavaAsset] with the required manifest and images.
  ///
  /// The [manifest] contains the animation metadata and frame information.
  /// The [images] list contains the loaded image atlas frames referenced by the manifest.
  LavaAsset({required this.manifest, required this.images});
}
