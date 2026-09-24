import 'package:fpdart/fpdart.dart';

import '../../../../core/use_cases/use_case.dart';
import '../entities/category.dart';
import '../entities/gender_selection.dart';
import '../entities/onboarding_draft.dart';

abstract class OnboardingRepository {
  /// The locally saved onboarding answers and completion flag.
  FutureEither<OnboardingDraft> loadState();

  FutureEither<Unit> saveBirthDate({
    required int year,
    required int month,
    required int day,
  });

  FutureEither<Unit> saveGender(GenderSelection gender);

  FutureEither<Unit> saveCategoryIds(List<String>? categoryIds);

  FutureEither<Unit> completeOnboarding();

  FutureEither<Unit> resetCompletion();

  FutureEither<bool> isCompleted();

  /// Interest categories, served from the local cache when one exists.
  FutureEither<List<Category>> getCategories();
}
