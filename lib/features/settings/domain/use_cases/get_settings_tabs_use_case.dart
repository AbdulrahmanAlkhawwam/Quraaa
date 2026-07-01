import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../entities/settings_tab.dart';
import '../repositories/settings_repository.dart';

class GetSettingsTabsUseCase
    extends UseCase<Result<List<SettingsTab>>, NoParams> {
  const GetSettingsTabsUseCase(this._repository);

  final SettingsRepository _repository;

  @override
  Future<Result<List<SettingsTab>>> call(NoParams params) {
    return _repository.getSettingsTabs();
  }
}
