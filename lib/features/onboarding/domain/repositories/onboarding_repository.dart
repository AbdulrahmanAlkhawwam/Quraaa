import '../entities/gender_selection.dart';
import '../entities/interest_selection.dart';
import '../entities/onboarding_draft.dart';

abstract class OnboardingRepository {
  Future<OnboardingDraft> loadState();

  Future<void> saveBirthDate({
    required int year,
    required int month,
    required int day,
  });

  Future<void> saveGender(GenderSelection gender);

  Future<void> saveInterests(List<InterestSelection> interests);

  Future<void> completeOnboarding();

  Future<void> resetCompletion();

  Future<bool> isCompleted();
}
