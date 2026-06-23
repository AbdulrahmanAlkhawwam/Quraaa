import '../../domain/entities/local_directory_snapshot.dart';
import '../models/local_path_segment_model.dart';

class LocalPathSegmentMapper {
  const LocalPathSegmentMapper();

  LocalPathSegment toEntity(LocalPathSegmentModel model) {
    return LocalPathSegment(
      label: model.label,
      path: model.path,
    );
  }

  LocalPathSegmentModel toModel(LocalPathSegment entity) {
    return LocalPathSegmentModel(
      label: entity.label,
      path: entity.path,
    );
  }
}
