enum LocalFileEntryType { directory, pdf, unsupported }

class LocalFileEntry {
  const LocalFileEntry({
    required this.name,
    required this.path,
    required this.type,
    required this.sizeBytes,
    this.modifiedAt,
  });

  final String name;
  final String path;
  final LocalFileEntryType type;
  final int sizeBytes;
  final DateTime? modifiedAt;

  bool get isDirectory => type == LocalFileEntryType.directory;

  bool get isPdf => type == LocalFileEntryType.pdf;

  bool get isSupported => isDirectory || isPdf;
}
