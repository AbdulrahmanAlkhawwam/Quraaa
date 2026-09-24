import 'package:fpdart/fpdart.dart';

import '../../../../core/use_cases/use_case.dart';
import '../entities/gender_selection.dart';
import '../repositories/onboarding_repository.dart';

class SaveGenderUseCase extends UseCase<Unit, GenderSelection> {
  const SaveGenderUseCase(this._repository);

  final OnboardingRepository _repository;

  @override
  FutureEither<Unit> call(GenderSelection params) {
    return _repository.saveGender(params);
  }
}
