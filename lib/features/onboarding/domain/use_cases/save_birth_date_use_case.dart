import '../../../../core/architecture/use_case.dart';
import '../repositories/onboarding_repository.dart';

class SaveBirthDateParams {
  const SaveBirthDateParams({
    required this.year,
    required this.month,
    required this.day,
  });

  final int year;
  final int month;
  final int day;
}

class SaveBirthDateUseCase extends UseCase<void, SaveBirthDateParams> {
  const SaveBirthDateUseCase(this._repository);

  final OnboardingRepository _repository;

  @override
  Future<void> call(SaveBirthDateParams params) {
    return _repository.saveBirthDate(
      year: params.year,
      month: params.month,
      day: params.day,
    );
  }
}
