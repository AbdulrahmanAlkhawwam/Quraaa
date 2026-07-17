import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/features/auth/presentation/bloc/auth_registration_cubit.dart';
import 'package:quraaa/features/onboarding/onboarding.dart';

void main() {
  test('load emits loaded registration data from onboarding use cases', () async {
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
    expect(cubit.state.birthYear, 2000);
    expect(cubit.state.birthMonth, 5);
    expect(cubit.state.birthDay, 10);
    expect(cubit.state.selectedGender, GenderSelection.boy);
    expect(cubit.state.selectedCategoryIds, <String>['fiction']);
    expect(cubit.state.validCategoryIds, <String>['fiction', 'science']);
  });

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
  Future<OnboardingDraft> loadState() async {
    return const OnboardingDraft(
      completed: false,
      selectedGender: GenderSelection.boy,
      selectedCategoryIds: <String>['fiction'],
      birthYear: 2000,
      birthMonth: 5,
      birthDay: 10,
    );
  }

  @override
  Future<List<Category>> getCategories() async {
    return const <Category>[
      Category(id: 'fiction', nameAr: 'Fiction', nameEn: 'Fiction'),
      Category(id: 'science', nameAr: 'Science', nameEn: 'Science'),
    ];
  }

  @override
  Future<void> completeOnboarding() async {}

  @override
  Future<bool> isCompleted() async => false;

  @override
  Future<void> resetCompletion() async {}

  @override
  Future<void> saveBirthDate({
    required int year,
    required int month,
    required int day,
  }) async {}

  @override
  Future<void> saveCategoryIds(List<String>? categoryIds) async {}

  @override
  Future<void> saveGender(GenderSelection gender) async {}
}

class _ThrowingOnboardingRepository extends _FakeOnboardingRepository {
  const _ThrowingOnboardingRepository();

  @override
  Future<OnboardingDraft> loadState() async {
    throw StateError('cannot load');
  }
}

