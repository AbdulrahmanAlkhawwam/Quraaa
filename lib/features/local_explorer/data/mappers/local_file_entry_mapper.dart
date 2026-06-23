import '../../domain/entities/local_file_entry.dart';
import '../models/local_file_entry_model.dart';

class LocalFileEntryMapper {
  const LocalFileEntryMapper();

  LocalFileEntry toEntity(LocalFileEntryModel model) {
    return LocalFileEntry(
      name: model.name,
      path: model.path,
      type: _toEntityType(model.type),
      sizeBytes: model.sizeBytes,
      modifiedAt: model.modifiedAt,
    );
  }

  LocalFileEntryModel toModel(LocalFileEntry entity) {
    return LocalFileEntryModel(
      name: entity.name,
      path: entity.path,
      type: _toModelType(entity.type),
      sizeBytes: entity.sizeBytes,
      modifiedAt: entity.modifiedAt,
    );
  }

  LocalFileEntryType _toEntityType(LocalFileEntryModelType type) {
    return switch (type) {
      LocalFileEntryModelType.directory => LocalFileEntryType.directory,
      LocalFileEntryModelType.pdf => LocalFileEntryType.pdf,
      LocalFileEntryModelType.unsupported => LocalFileEntryType.unsupported,
    };
  }

  LocalFileEntryModelType _toModelType(LocalFileEntryType type) {
    return switch (type) {
      LocalFileEntryType.directory => LocalFileEntryModelType.directory,
      LocalFileEntryType.pdf => LocalFileEntryModelType.pdf,
      LocalFileEntryType.unsupported => LocalFileEntryModelType.unsupported,
    };
  }
}
