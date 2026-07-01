import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../entities/settings_section.dart';
import '../repositories/settings_repository.dart';

class GetActivitySectionsUseCase
    extends UseCase<Result<List<SettingsSection>>, NoParams> {
  const GetActivitySectionsUseCase(this._repository);

  final SettingsRepository _repository;

  @override
  Future<Result<List<SettingsSection>>> call(NoParams params) {
    return _repository.getActivitySections();
  }
}
