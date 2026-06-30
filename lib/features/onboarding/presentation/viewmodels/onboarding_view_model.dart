import '../../../../core/architecture/use_case.dart';
import '../../domain/entities/gender_selection.dart';
import '../../domain/entities/interest_selection.dart';
import '../../domain/entities/onboarding_draft.dart';
import '../../domain/use_cases/complete_onboarding_use_case.dart';
import '../../domain/use_cases/load_onboarding_state_use_case.dart';
import '../../domain/use_cases/save_birth_date_use_case.dart';
import '../../domain/use_cases/save_interests_use_case.dart';
import '../../domain/use_cases/save_gender_use_case.dart';

class OnboardingViewModel {
  const OnboardingViewModel(
    this._loadOnboardingStateUseCase,
    this._saveBirthDateUseCase,
    this._saveGenderUseCase,
    this._saveInterestsUseCase,
    this._completeOnboardingUseCase,
  );

  final LoadOnboardingStateUseCase _loadOnboardingStateUseCase;
  final SaveBirthDateUseCase _saveBirthDateUseCase;
  final SaveGenderUseCase _saveGenderUseCase;
  final SaveInterestsUseCase _saveInterestsUseCase;
  final CompleteOnboardingUseCase _completeOnboardingUseCase;

  Future<OnboardingDraft> loadState() {
    return _loadOnboardingStateUseCase(const NoParams());
  }

  Future<void> saveBirthDate({
    required int year,
    required int month,
    required int day,
  }) {
    return _saveBirthDateUseCase(
      SaveBirthDateParams(
        year: year,
        month: month,
        day: day,
      ),
    );
  }

  Future<void> selectGender(GenderSelection gender) {
    return _saveGenderUseCase(gender);
  }

  Future<void> saveInterests(List<InterestSelection> interests) {
    return _saveInterestsUseCase(SaveInterestsParams(interests));
  }

  Future<void> completeOnboarding() {
    return _completeOnboardingUseCase(const NoParams());
  }
}
