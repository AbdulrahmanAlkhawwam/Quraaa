import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../entities/settings_section.dart';
import '../repositories/settings_repository.dart';

class GetLibrarySectionsUseCase
    extends UseCase<Result<List<SettingsSection>>, NoParams> {
  const GetLibrarySectionsUseCase(this._repository);

  final SettingsRepository _repository;

  @override
  Future<Result<List<SettingsSection>>> call(NoParams params) {
    return _repository.getLibrarySections();
  }
}
