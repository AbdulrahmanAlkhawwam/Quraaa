import '../../domain/entities/local_directory_snapshot.dart';
import '../models/local_directory_snapshot_model.dart';
import 'local_file_entry_mapper.dart';
import 'local_path_segment_mapper.dart';

class LocalDirectorySnapshotMapper {
  const LocalDirectorySnapshotMapper({
    this.entryMapper = const LocalFileEntryMapper(),
    this.segmentMapper = const LocalPathSegmentMapper(),
  });

  final LocalFileEntryMapper entryMapper;
  final LocalPathSegmentMapper segmentMapper;

  LocalDirectorySnapshot toEntity(LocalDirectorySnapshotModel model) {
    return LocalDirectorySnapshot(
      currentPath: model.currentPath,
      breadcrumbs: model.breadcrumbs
          .map(segmentMapper.toEntity)
          .toList(growable: false),
      entries:
          model.entries.map(entryMapper.toEntity).toList(growable: false),
    );
  }

  LocalDirectorySnapshotModel toModel(LocalDirectorySnapshot entity) {
    return LocalDirectorySnapshotModel(
      currentPath: entity.currentPath,
      breadcrumbs: entity.breadcrumbs
          .map(segmentMapper.toModel)
          .toList(growable: false),
      entries:
          entity.entries.map(entryMapper.toModel).toList(growable: false),
    );
  }
}
