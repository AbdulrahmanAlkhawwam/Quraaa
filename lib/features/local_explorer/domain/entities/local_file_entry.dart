import 'package:equatable/equatable.dart';

enum LocalFileEntryType { directory, pdf, unsupported }

class LocalFileEntry extends Equatable {
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

  @override
  List<Object?> get props => <Object?>[
        name,
        path,
        type,
        sizeBytes,
        modifiedAt,
      ];
}
