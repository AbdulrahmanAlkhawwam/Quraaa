import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../entities/language_option.dart';
import '../repositories/settings_repository.dart';

class UpdateLanguageOptionParams {
  const UpdateLanguageOptionParams({required this.id});

  final String id;
}

class UpdateLanguageOptionUseCase
    extends UseCase<Result<List<LanguageOption>>, UpdateLanguageOptionParams> {
  const UpdateLanguageOptionUseCase(this._repository);

  final SettingsRepository _repository;

  @override
  Future<Result<List<LanguageOption>>> call(UpdateLanguageOptionParams params) {
    return _repository.updateLanguageOption(params.id);
  }
}
