import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../entities/appearance_option.dart';
import '../repositories/settings_repository.dart';

class GetAppearanceOptionsUseCase
    extends UseCase<Result<List<AppearanceOption>>, NoParams> {
  const GetAppearanceOptionsUseCase(this._repository);

  final SettingsRepository _repository;

  @override
  Future<Result<List<AppearanceOption>>> call(NoParams params) {
    return _repository.getAppearanceOptions();
  }
}
