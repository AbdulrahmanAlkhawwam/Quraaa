/// Identifies the source of an image path or payload.
enum ImageSource {
  /// An inline SVG/XML string.
  inlineSvg,

  /// A Flutter asset declared in pubspec.yaml.
  asset,

  /// A remote HTTP/HTTPS URL.
  network,

  /// A path on the local file system.
  file,

  /// A value that does not match any known source.
  unknown,
}

/// Helpers for working with image paths and payloads.
///
/// The helpers are pure functions with no side effects and can be used from
/// widgets, blocs, or tests without depending on Flutter's asset or network
/// stack.
class ImageHelper {
  ImageHelper._();

  /// Returns `true` when [path] represents an SVG payload.
  ///
  /// Detection ignores URI query parameters and fragments, is case-insensitive,
  /// and checks whether the path ends with the `.svg` extension.
  static bool isSvg(String path) {
    final trimmed = path.trim();
    final uri = Uri.tryParse(trimmed);
    final filePath = uri?.path ?? trimmed;
    return filePath.toLowerCase().endsWith('.svg');
  }

  /// Detects the image source for [path].
  ///
  /// When [isFile] is `true` and the source cannot otherwise be identified,
  /// [ImageSource.file] is returned.
  static ImageSource detectSource(String path, {bool isFile = false}) {
    final trimmed = path.trim();
    if (trimmed.startsWith('<svg') || trimmed.startsWith('<?xml')) {
      return ImageSource.inlineSvg;
    }
    if (trimmed.startsWith('assets')) {
      return ImageSource.asset;
    }
    if (trimmed.startsWith('http')) {
      return ImageSource.network;
    }
    if (isFile) {
      return ImageSource.file;
    }
    return ImageSource.unknown;
  }
}
