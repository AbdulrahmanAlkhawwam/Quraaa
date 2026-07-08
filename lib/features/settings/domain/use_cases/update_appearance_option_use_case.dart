import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../entities/appearance_option.dart';
import '../repositories/settings_repository.dart';

class UpdateAppearanceOptionParams {
  const UpdateAppearanceOptionParams({required this.id});

  final String id;
}

class UpdateAppearanceOptionUseCase
    extends UseCase<Result<List<AppearanceOption>>, UpdateAppearanceOptionParams> {
  const UpdateAppearanceOptionUseCase(this._repository);

  final SettingsRepository _repository;

  @override
  Future<Result<List<AppearanceOption>>> call(
    UpdateAppearanceOptionParams params,
  ) {
    return _repository.updateAppearanceOption(params.id);
  }
}
