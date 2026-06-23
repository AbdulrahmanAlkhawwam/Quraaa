enum LocalFileEntryModelType { directory, pdf, unsupported }

class LocalFileEntryModel {
  const LocalFileEntryModel({
    required this.name,
    required this.path,
    required this.type,
    required this.sizeBytes,
    this.modifiedAt,
  });

  final String name;
  final String path;
  final LocalFileEntryModelType type;
  final int sizeBytes;
  final DateTime? modifiedAt;
}
