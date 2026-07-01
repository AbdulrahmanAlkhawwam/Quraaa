import '../../../../core/architecture/use_case.dart';
import '../repositories/onboarding_repository.dart';

class CompleteOnboardingUseCase extends UseCase<void, NoParams> {
  const CompleteOnboardingUseCase(this._repository);

  final OnboardingRepository _repository;

  @override
  Future<void> call(NoParams params) {
    return _repository.completeOnboarding();
  }
}
