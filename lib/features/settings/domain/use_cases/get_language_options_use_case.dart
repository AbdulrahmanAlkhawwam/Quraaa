import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../entities/language_option.dart';
import '../repositories/settings_repository.dart';

class GetLanguageOptionsUseCase
    extends UseCase<Result<List<LanguageOption>>, NoParams> {
  const GetLanguageOptionsUseCase(this._repository);

  final SettingsRepository _repository;

  @override
  Future<Result<List<LanguageOption>>> call(NoParams params) {
    return _repository.getLanguageOptions();
  }
}
