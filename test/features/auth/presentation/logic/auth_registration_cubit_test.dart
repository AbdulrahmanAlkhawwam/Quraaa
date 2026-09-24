import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:quraaa/core/errors/failures.dart';
import 'package:quraaa/core/use_cases/use_case.dart';
import 'package:quraaa/features/auth/presentation/logic/auth_registration_cubit.dart';
import 'package:quraaa/features/onboarding/onboarding.dart';

void main() {
  test(
    'load emits loaded registration data from onboarding use cases',
    () async {
      final AuthRegistrationCubit cubit = AuthRegistrationCubit(
        loadOnboardingStateUseCase: LoadOnboardingStateUseCase(
          const _FakeOnboardingRepository(),
        ),
        loadCategoriesUseCase: LoadCategoriesUseCase(
          const _FakeOnboardingRepository(),
        ),
      );
      addTearDown(cubit.close);

      await cubit.load();

      expect(cubit.state.status, AuthRegistrationStatus.loaded);
      expect(cubit.state.hasRequiredOnboardingData, isTrue);
      expect(cubit.state.birthYear, 2000);
      expect(cubit.state.birthMonth, 5);
      expect(cubit.state.birthDay, 10);
      expect(cubit.state.selectedGender, GenderSelection.boy);
      expect(cubit.state.selectedCategoryIds, <String>[
        '3fa85f64-5717-4562-b3fc-2c963f66afa6',
      ]);
      expect(cubit.state.validCategoryIds, <String>[
        '3fa85f64-5717-4562-b3fc-2c963f66afa6',
        '550e8400-e29b-41d4-a716-446655440000',
      ]);
    },
  );

  test('load emits failure when registration data cannot be loaded', () async {
    final AuthRegistrationCubit cubit = AuthRegistrationCubit(
      loadOnboardingStateUseCase: LoadOnboardingStateUseCase(
        const _ThrowingOnboardingRepository(),
      ),
      loadCategoriesUseCase: LoadCategoriesUseCase(
        const _ThrowingOnboardingRepository(),
      ),
    );
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state.status, AuthRegistrationStatus.failure);
    expect(cubit.state.errorMessage, isNotNull);
  });
}

class _FakeOnboardingRepository implements OnboardingRepository {
  const _FakeOnboardingRepository();

  @override
  FutureEither<OnboardingDraft> loadState() async {
    return const Right(OnboardingDraft(
      completed: true,
      selectedGender: GenderSelection.boy,
      selectedCategoryIds: <String>['3fa85f64-5717-4562-b3fc-2c963f66afa6'],
      birthYear: 2000,
      birthMonth: 5,
      birthDay: 10,
    ));
  }

  @override
  FutureEither<List<Category>> getCategories() async {
    return const Right(<Category>[
      Category(
        id: '3fa85f64-5717-4562-b3fc-2c963f66afa6',
        nameAr: 'Fiction',
        nameEn: 'Fiction',
      ),
      Category(
        id: '550e8400-e29b-41d4-a716-446655440000',
        nameAr: 'Science',
        nameEn: 'Science',
      ),
    ]);
  }

  @override
  FutureEither<Unit> completeOnboarding() async => const Right(unit);

  @override
  FutureEither<bool> isCompleted() async => const Right(false);

  @override
  FutureEither<Unit> resetCompletion() async => const Right(unit);

  @override
  FutureEither<Unit> saveBirthDate({
    required int year,
    required int month,
    required int day,
  }) async => const Right(unit);

  @override
  FutureEither<Unit> saveCategoryIds(List<String>? categoryIds) async =>
      const Right(unit);

  @override
  FutureEither<Unit> saveGender(GenderSelection gender) async =>
      const Right(unit);
}

class _ThrowingOnboardingRepository extends _FakeOnboardingRepository {
  const _ThrowingOnboardingRepository();

  @override
  FutureEither<OnboardingDraft> loadState() async =>
      const Left(CacheReadFailure());
}
