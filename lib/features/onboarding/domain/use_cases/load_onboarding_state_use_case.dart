import '../../../../core/use_cases/use_case.dart';
import '../entities/onboarding_draft.dart';
import '../repositories/onboarding_repository.dart';

class LoadOnboardingStateUseCase extends NoParamsUseCase<OnboardingDraft> {
  const LoadOnboardingStateUseCase(this._repository);

  final OnboardingRepository _repository;

  @override
  FutureEither<OnboardingDraft> call() {
    return _repository.loadState();
  }
}
