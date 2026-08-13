import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/features/auth/presentation/bloc/auth_registration_cubit.dart';
import 'package:quraaa/features/onboarding/onboarding.dart';

void main() {
  const List<Category> categories = <Category>[
    Category(
      id: '3fa85f64-5717-4562-b3fc-2c963f66afa6',
      nameAr: 'روايات',
      nameEn: 'Fiction',
    ),
  ];

  test('registration requires completed gender age and interests', () {
    const AuthRegistrationState valid = AuthRegistrationState(
      status: AuthRegistrationStatus.loaded,
      onboardingCompleted: true,
      selectedGender: GenderSelection.boy,
      birthYear: 2000,
      birthMonth: 5,
      birthDay: 10,
      categories: categories,
      selectedCategoryIds: <String>['3fa85f64-5717-4562-b3fc-2c963f66afa6'],
    );

    expect(valid.hasRequiredOnboardingData, isTrue);
    expect(
      AuthRegistrationState(
        status: AuthRegistrationStatus.loaded,
        onboardingCompleted: false,
        selectedGender: valid.selectedGender,
        birthYear: valid.birthYear,
        birthMonth: valid.birthMonth,
        birthDay: valid.birthDay,
        categories: categories,
        selectedCategoryIds: valid.selectedCategoryIds,
      ).hasRequiredOnboardingData,
      isFalse,
    );
    expect(
      const AuthRegistrationState(
        status: AuthRegistrationStatus.loaded,
        onboardingCompleted: true,
        birthYear: 2000,
        birthMonth: 5,
        birthDay: 10,
        categories: categories,
        selectedCategoryIds: <String>['3fa85f64-5717-4562-b3fc-2c963f66afa6'],
      ).hasRequiredOnboardingData,
      isFalse,
    );
    expect(
      const AuthRegistrationState(
        status: AuthRegistrationStatus.loaded,
        onboardingCompleted: true,
        selectedGender: GenderSelection.boy,
        categories: categories,
        selectedCategoryIds: <String>['3fa85f64-5717-4562-b3fc-2c963f66afa6'],
      ).hasRequiredOnboardingData,
      isFalse,
    );
    expect(
      const AuthRegistrationState(
        status: AuthRegistrationStatus.loaded,
        onboardingCompleted: true,
        selectedGender: GenderSelection.boy,
        birthYear: 2000,
        birthMonth: 5,
        birthDay: 10,
        categories: categories,
      ).hasRequiredOnboardingData,
      isFalse,
    );
  });
}
