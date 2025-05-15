/// Supported versions of the Lava animation format.
///
/// Currently only version 1 is supported by the library.
enum LavaVersion {
  /// Version 1 of the Lava animation format.
  v1;

  /// Converts an integer version number to the corresponding [LavaVersion] enum value.
  ///
  /// Throws an [ArgumentError] if the version is not supported.
  static LavaVersion fromInt(int value) {
    switch (value) {
      case 1:
        return LavaVersion.v1;
      default:
        throw ArgumentError('Unknown LavaVersion: $value');
    }
  }
}

/// Represents an image atlas frame in a Lava animation.
///
/// Each image contains a portion of the animation frames or tiles
/// that are referenced by the animation frames.
class LavaImage {
  /// The relative URL path to the image file within the animation directory.
  final String url;

  /// Creates a new [LavaImage] with the specified URL.
  LavaImage({required this.url});

  /// Creates a [LavaImage] from a JSON object.
  ///
  /// The JSON object must contain a 'url' field.
  factory LavaImage.fromJson(Map<String, dynamic> json) {
    return LavaImage(url: json['url']);
  }
}

/// Base class for all types of frames in a Lava animation.
///
/// A Lava animation consists of a sequence of frames, which can be
/// either keyframes (containing a full image) or diff frames
/// (containing only the differences from the previous frame).
abstract class LavaFrame {
  /// Creates a [LavaFrame] from a JSON object.
  ///
  /// The type of frame created depends on the 'type' field in the JSON object.
  /// Currently supported types are 'key' for [LavaKeyFrame] and 'diff' for [LavaDiffFrame].
  ///
  /// Throws an [ArgumentError] if the frame type is not supported.
  factory LavaFrame.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    switch (type) {
      case 'key':
        return LavaKeyFrame.fromJson(json);
      case 'diff':
        return LavaDiffFrame.fromJson(json);
      default:
        throw ArgumentError('Unknown frame type: $type');
    }
  }
}

/// A keyframe in a Lava animation.
///
/// A keyframe contains a reference to a complete image that represents
/// the entire frame, rather than just the differences from the previous frame.
class LavaKeyFrame implements LavaFrame {
  /// The index of the image in the [LavaManifest.images] list that contains this keyframe.
  final int imageIndex;

  /// Creates a new [LavaKeyFrame] with the specified image index.
  LavaKeyFrame({required this.imageIndex});

  /// Creates a [LavaKeyFrame] from a JSON object.
  ///
  /// The JSON object must contain an 'imageIndex' field.
  factory LavaKeyFrame.fromJson(Map<String, dynamic> json) {
    return LavaKeyFrame(imageIndex: json['imageIndex']);
  }
}

/// A diff frame in a Lava animation.
///
/// A diff frame contains only the differences from the base frame,
/// which allows for more efficient storage and rendering of animations.
class LavaDiffFrame implements LavaFrame {
  /// The list of diff operations to apply to render this frame.
  ///
  /// Each diff is a list of integers with the format:
  /// [srcImageIndex, srcTileIndex, countX, countY, destTileIndex]
  /// - srcImageIndex: Index of the source image in the images list
  /// - srcTileIndex: Index of the tile in the source image
  /// - countX: Number of tiles horizontally
  /// - countY: Number of tiles vertically
  /// - destTileIndex: Index of the destination tile in the frame
  final List<List<int>> diffs;

  /// Creates a new [LavaDiffFrame] with the specified diffs.
  LavaDiffFrame({required this.diffs});

  /// Creates a [LavaDiffFrame] from a JSON object.
  ///
  /// The JSON object must contain a 'diffs' field with an array of diff operations.
  factory LavaDiffFrame.fromJson(Map<String, dynamic> json) {
    return LavaDiffFrame(
      diffs: (json['diffs'] as List).map((row) => List<int>.from(row)).toList(),
    );
  }
}

/// The main manifest class for a Lava animation.
///
/// Contains all the metadata and frame information needed to render
/// a Lava animation, including animation dimensions, frame rate,
/// and references to image atlas frames.
class LavaManifest {
  /// The version of the Lava animation format.
  final LavaVersion version;

  /// The frame rate of the animation in frames per second.
  final int fps;

  /// The size of each tile cell in pixels.
  final int cellSize;

  /// The size of the diff image in pixels.
  final int diffImageSize;

  /// The width of the animation in pixels.
  final int width;

  /// The height of the animation in pixels.
  final int height;

  /// The pixel density of the animation.
  final int density;

  /// Whether the animation has alpha transparency.
  final bool alpha;

  /// The list of image atlas frames used by the animation.
  final List<LavaImage> images;

  /// The list of animation frames.
  final List<LavaFrame> frames;

  /// Creates a new [LavaManifest] with the specified properties.
  LavaManifest({
    required this.version,
    required this.fps,
    required this.cellSize,
    required this.diffImageSize,
    required this.width,
    required this.height,
    required this.density,
    required this.alpha,
    required this.images,
    required this.frames,
  });

  /// Creates a [LavaManifest] from a JSON object.
  ///
  /// The JSON object must contain all the required fields for a Lava animation manifest.
  factory LavaManifest.fromJson(Map<String, dynamic> json) {
    return LavaManifest(
      version: LavaVersion.fromInt(json['version']),
      fps: json['fps'],
      cellSize: json['cellSize'],
      diffImageSize: json['diffImageSize'],
      width: json['width'],
      height: json['height'],
      density: json['density'],
      alpha: json['alpha'],
      images: (json['images'] as List).map((img) => LavaImage.fromJson(img)).toList(),
      frames: (json['frames'] as List).map((f) => LavaFrame.fromJson(f)).toList(),
    );
  }
}
