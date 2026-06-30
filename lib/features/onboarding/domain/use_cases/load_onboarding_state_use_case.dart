import '../../../../core/architecture/use_case.dart';
import '../entities/onboarding_draft.dart';
import '../repositories/onboarding_repository.dart';

class LoadOnboardingStateUseCase extends UseCase<OnboardingDraft, NoParams> {
  const LoadOnboardingStateUseCase(this._repository);

  final OnboardingRepository _repository;

  @override
  Future<OnboardingDraft> call(NoParams params) {
    return _repository.loadState();
  }
}
