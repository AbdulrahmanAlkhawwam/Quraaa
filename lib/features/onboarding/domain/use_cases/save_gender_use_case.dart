import '../../../../core/architecture/use_case.dart';
import '../entities/gender_selection.dart';
import '../repositories/onboarding_repository.dart';

class SaveGenderUseCase extends UseCase<void, GenderSelection> {
  const SaveGenderUseCase(this._repository);

  final OnboardingRepository _repository;

  @override
  Future<void> call(GenderSelection params) {
    return _repository.saveGender(params);
  }
}
