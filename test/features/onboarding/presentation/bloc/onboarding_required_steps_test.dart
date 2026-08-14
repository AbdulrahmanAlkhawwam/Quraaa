import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/features/onboarding/domain/entities/gender_selection.dart';
import 'package:quraaa/features/onboarding/domain/entities/category.dart';
import 'package:quraaa/features/onboarding/presentation/bloc/onboarding_bloc.dart';

void main() {
  test('each onboarding step requires its value before continuing', () {
    const OnboardingState empty = OnboardingState();
    expect(empty.canContinueGender, isFalse);
    expect(empty.canContinueAge, isFalse);
    expect(empty.canContinueCategory, isFalse);

    const OnboardingState completedValues = OnboardingState(
      selectedGender: GenderSelection.girl,
      birthYear: 2000,
      birthMonth: 5,
      birthDay: 10,
      categories: <Category>[
        Category(
          id: '3fa85f64-5717-4562-b3fc-2c963f66afa6',
          nameAr: 'روايات',
          nameEn: 'Fiction',
        ),
      ],
      selectedCategoryIds: <String>['3fa85f64-5717-4562-b3fc-2c963f66afa6'],
    );
    expect(completedValues.canContinueGender, isTrue);
    expect(completedValues.canContinueAge, isTrue);
    expect(completedValues.canContinueCategory, isTrue);
  });

  test('age outside the supported range cannot continue', () {
    final DateTime now = DateTime.now();
    final OnboardingState tooYoung = OnboardingState(
      selectedGender: GenderSelection.boy,
      birthYear: now.year - 2,
      birthMonth: now.month,
      birthDay: now.day,
    );

    expect(tooYoung.canContinueAge, isFalse);
  });

  test('completed onboarding keeps gender present for route guards', () {
    const OnboardingState completed = OnboardingState(
      selectedGender: GenderSelection.girl,
      birthYear: 2000,
      birthMonth: 5,
      birthDay: 10,
      selectedCategoryIds: <String>['3fa85f64-5717-4562-b3fc-2c963f66afa6'],
      isCompleted: true,
    );

    expect(completed.hasGender, isTrue);
    expect(completed.isBirthDateValid, isTrue);
    expect(completed.canContinueGender, isFalse);
  });
}
