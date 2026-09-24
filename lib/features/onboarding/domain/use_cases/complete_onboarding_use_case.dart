import 'package:fpdart/fpdart.dart';

import '../../../../core/use_cases/use_case.dart';
import '../repositories/onboarding_repository.dart';

class CompleteOnboardingUseCase extends NoParamsUseCase<Unit> {
  const CompleteOnboardingUseCase(this._repository);

  final OnboardingRepository _repository;

  @override
  FutureEither<Unit> call() {
    return _repository.completeOnboarding();
  }
}
