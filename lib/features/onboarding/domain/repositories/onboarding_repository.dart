import '../entities/category.dart';
import '../entities/gender_selection.dart';
import '../entities/onboarding_draft.dart';

abstract class OnboardingRepository {
  Future<OnboardingDraft> loadState();

  Future<void> saveBirthDate({
    required int year,
    required int month,
    required int day,
  });

  Future<void> saveGender(GenderSelection gender);

  Future<void> saveCategoryIds(List<String>? categoryIds);

  Future<void> completeOnboarding();

  Future<void> resetCompletion();

  Future<bool> isCompleted();

  Future<List<Category>> getCategories();
}
