import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/core/constants/app_routes.dart';
import 'package:quraaa/core/routing/route_resolver.dart';
import 'package:quraaa/features/onboarding/domain/entities/gender_selection.dart';
import 'package:quraaa/features/onboarding/domain/entities/onboarding_draft.dart';

void main() {
  group('resolveRegistrationDraftRoute', () {
    test('starts at gender when gender is missing', () {
      expect(resolveRegistrationDraftRoute(_draft()), AppRoutes.onboarding);
    });

    test('requires age after gender', () {
      expect(
        resolveRegistrationDraftRoute(
          _draft(selectedGender: GenderSelection.boy),
        ),
        AppRoutes.onboardingAge,
      );
    });

    test('requires interests after gender and a valid age', () {
      expect(
        resolveRegistrationDraftRoute(
          _draft(
            selectedGender: GenderSelection.girl,
            birthYear: 2000,
            birthMonth: 5,
            birthDay: 10,
          ),
        ),
        AppRoutes.onboardingInterests,
      );
    });

    test('does not open register before onboarding is completed', () {
      expect(
        resolveRegistrationDraftRoute(
          _draft(
            selectedGender: GenderSelection.girl,
            birthYear: 2000,
            birthMonth: 5,
            birthDay: 10,
            selectedCategoryIds: const <String>['fiction'],
          ),
        ),
        AppRoutes.onboardingInterests,
      );
    });

    test('opens register only when every required step is completed', () {
      expect(
        resolveRegistrationDraftRoute(
          _draft(
            completed: true,
            selectedGender: GenderSelection.boy,
            birthYear: 2000,
            birthMonth: 5,
            birthDay: 10,
            selectedCategoryIds: const <String>['fiction'],
          ),
        ),
        AppRoutes.register,
      );
    });

    test('ignores a stale completed flag when required data is missing', () {
      expect(
        resolveRegistrationDraftRoute(_draft(completed: true)),
        AppRoutes.onboarding,
      );
    });
  });
}

OnboardingDraft _draft({
  bool completed = false,
  GenderSelection? selectedGender,
  List<String>? selectedCategoryIds,
  int? birthYear,
  int? birthMonth,
  int? birthDay,
}) {
  return OnboardingDraft(
    completed: completed,
    selectedGender: selectedGender,
    selectedCategoryIds: selectedCategoryIds,
    birthYear: birthYear,
    birthMonth: birthMonth,
    birthDay: birthDay,
  );
}
