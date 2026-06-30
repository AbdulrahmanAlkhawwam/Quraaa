import '../../../../core/architecture/use_case.dart';
import '../entities/interest_selection.dart';
import '../repositories/onboarding_repository.dart';

class SaveInterestsParams {
  const SaveInterestsParams(this.interests);

  final List<InterestSelection> interests;
}

class SaveInterestsUseCase extends UseCase<void, SaveInterestsParams> {
  const SaveInterestsUseCase(this._repository);

  final OnboardingRepository _repository;

  @override
  Future<void> call(SaveInterestsParams params) {
    return _repository.saveInterests(params.interests);
  }
}
