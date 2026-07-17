import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/architecture/use_case.dart';
import '../../../onboarding/onboarding.dart';

enum AuthRegistrationStatus { initial, loading, loaded, failure }

class AuthRegistrationState extends Equatable {
  const AuthRegistrationState({
    this.status = AuthRegistrationStatus.initial,
    this.birthYear,
    this.birthMonth,
    this.birthDay,
    this.selectedGender,
    this.categories = const <Category>[],
    this.selectedCategoryIds = const <String>[],
    this.errorMessage,
  });

  final AuthRegistrationStatus status;
  final int? birthYear;
  final int? birthMonth;
  final int? birthDay;
  final GenderSelection? selectedGender;
  final List<Category> categories;
  final List<String> selectedCategoryIds;
  final String? errorMessage;

  bool get isLoading => status == AuthRegistrationStatus.loading;

  List<String> get validCategoryIds => categories
      .map((Category category) => category.id)
      .toList(growable: false);

  @override
  List<Object?> get props => <Object?>[
        status,
        birthYear,
        birthMonth,
        birthDay,
        selectedGender,
        categories,
        selectedCategoryIds,
        errorMessage,
      ];
}

class AuthRegistrationCubit extends Cubit<AuthRegistrationState> {
  AuthRegistrationCubit({
    required LoadOnboardingStateUseCase loadOnboardingStateUseCase,
    required LoadCategoriesUseCase loadCategoriesUseCase,
  })  : _loadOnboardingStateUseCase = loadOnboardingStateUseCase,
        _loadCategoriesUseCase = loadCategoriesUseCase,
        super(const AuthRegistrationState());

  final LoadOnboardingStateUseCase _loadOnboardingStateUseCase;
  final LoadCategoriesUseCase _loadCategoriesUseCase;

  Future<void> load() async {
    emit(const AuthRegistrationState(status: AuthRegistrationStatus.loading));
    try {
      final OnboardingDraft draft = await _loadOnboardingStateUseCase(
        const NoParams(),
      );
      final List<Category> categories = await _loadCategoriesUseCase(
        const NoParams(),
      );
      emit(
        AuthRegistrationState(
          status: AuthRegistrationStatus.loaded,
          birthYear: draft.birthYear,
          birthMonth: draft.birthMonth,
          birthDay: draft.birthDay,
          selectedGender: draft.selectedGender,
          categories: categories,
          selectedCategoryIds: draft.selectedCategoryIds ?? const <String>[],
        ),
      );
    } catch (_) {
      emit(
        const AuthRegistrationState(
          status: AuthRegistrationStatus.failure,
          errorMessage: 'Failed to load registration data',
        ),
      );
    }
  }
}
