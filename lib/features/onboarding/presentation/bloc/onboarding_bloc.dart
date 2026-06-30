import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/architecture/use_case.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/gender_selection.dart';
import '../../domain/entities/onboarding_draft.dart';
import '../../domain/use_cases/complete_onboarding_use_case.dart';
import '../../domain/use_cases/load_categories_use_case.dart';
import '../../domain/use_cases/load_onboarding_state_use_case.dart';
import '../../domain/use_cases/save_birth_date_use_case.dart';
import '../../domain/use_cases/save_category_id_use_case.dart';
import '../../domain/use_cases/save_gender_use_case.dart';

sealed class OnboardingEvent {
  const OnboardingEvent();
}

final class OnboardingStarted extends OnboardingEvent {
  const OnboardingStarted();
}

final class OnboardingAgeYearChanged extends OnboardingEvent {
  const OnboardingAgeYearChanged(this.year);

  final int? year;
}

final class OnboardingAgeMonthChanged extends OnboardingEvent {
  const OnboardingAgeMonthChanged(this.month);

  final int? month;
}

final class OnboardingAgeDayChanged extends OnboardingEvent {
  const OnboardingAgeDayChanged(this.day);

  final int? day;
}

final class OnboardingAgeNextRequested extends OnboardingEvent {
  const OnboardingAgeNextRequested();
}

final class OnboardingGenderSelected extends OnboardingEvent {
  const OnboardingGenderSelected(this.gender);

  final GenderSelection gender;
}

final class OnboardingCategorySelected extends OnboardingEvent {
  const OnboardingCategorySelected(this.categoryId);

  final String categoryId;
}

final class OnboardingInterestsNextRequested extends OnboardingEvent {
  const OnboardingInterestsNextRequested();
}

final class OnboardingSkipRequested extends OnboardingEvent {
  const OnboardingSkipRequested();
}

final class OnboardingNextRequested extends OnboardingEvent {
  const OnboardingNextRequested();
}

  final class OnboardingNavigationCompleted extends OnboardingEvent {
  const OnboardingNavigationCompleted();
}

class OnboardingState {
  const OnboardingState({
    this.birthYear,
    this.birthMonth,
    this.birthDay,
    this.selectedGender,
    this.categories = const <Category>[],
    this.selectedCategoryId,
    this.isLoading = false,
    this.isCompleted = false,
    this.navigationTarget,
    this.errorMessage,
  });

  static const Object _unset = Object();

  final int? birthYear;
  final int? birthMonth;
  final int? birthDay;
  final GenderSelection? selectedGender;
  final List<Category> categories;
  final String? selectedCategoryId;
  final bool isLoading;
  final bool isCompleted;
  final String? navigationTarget;
  final String? errorMessage;

  bool get hasBirthDate =>
      birthYear != null && birthMonth != null && birthDay != null;

  bool get isBirthDateValid {
    if (!hasBirthDate) {
      return false;
    }

    final DateTime? date = _tryParseBirthDate(
      birthYear!,
      birthMonth!,
      birthDay!,
    );
    if (date == null) {
      return false;
    }

    final int currentYear = DateTime.now().year;
    final DateTime now = DateTime.now();
    return birthYear! >= 1900 &&
        birthYear! <= currentYear &&
        birthMonth! >= 1 &&
        birthMonth! <= 12 &&
        birthDay! >= 1 &&
        birthDay! <= 31 &&
        !date.isAfter(now);
  }

  bool get canContinueAge => isBirthDateValid && !isLoading && !isCompleted;

  bool get canContinueGender =>
      selectedGender != null && !isLoading && !isCompleted;

  bool get hasCategory => selectedCategoryId != null;

  bool get canContinueCategory =>
      hasCategory && !isLoading && !isCompleted;

  static DateTime? _tryParseBirthDate(int year, int month, int day) {
    try {
      final DateTime parsed = DateTime(year, month, day);
      if (parsed.year != year || parsed.month != month || parsed.day != day) {
        return null;
      }
      return parsed;
    } catch (_) {
      return null;
    }
  }

  OnboardingState copyWith({
    Object? birthYear = _unset,
    Object? birthMonth = _unset,
    Object? birthDay = _unset,
    Object? selectedGender = _unset,
    Object? categories = _unset,
    Object? selectedCategoryId = _unset,
    bool? isLoading,
    bool? isCompleted,
    Object? navigationTarget = _unset,
    Object? errorMessage = _unset,
  }) {
    return OnboardingState(
      birthYear:
          identical(birthYear, _unset) ? this.birthYear : birthYear as int?,
      birthMonth:
          identical(birthMonth, _unset) ? this.birthMonth : birthMonth as int?,
      birthDay: identical(birthDay, _unset) ? this.birthDay : birthDay as int?,
      selectedGender: identical(selectedGender, _unset)
          ? this.selectedGender
          : selectedGender as GenderSelection?,
      categories: identical(categories, _unset)
          ? this.categories
          : List<Category>.unmodifiable(categories as List<Category>),
      selectedCategoryId: identical(selectedCategoryId, _unset)
          ? this.selectedCategoryId
          : selectedCategoryId as String?,
      isLoading: isLoading ?? this.isLoading,
      isCompleted: isCompleted ?? this.isCompleted,
      navigationTarget: identical(navigationTarget, _unset)
          ? this.navigationTarget
          : navigationTarget as String?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc({
    required LoadOnboardingStateUseCase loadOnboardingStateUseCase,
    required SaveBirthDateUseCase saveBirthDateUseCase,
    required SaveGenderUseCase saveGenderUseCase,
    required SaveCategoryIdUseCase saveCategoryIdUseCase,
    required LoadCategoriesUseCase loadCategoriesUseCase,
    required CompleteOnboardingUseCase completeOnboardingUseCase,
  })  : _loadOnboardingStateUseCase = loadOnboardingStateUseCase,
        _saveBirthDateUseCase = saveBirthDateUseCase,
        _saveGenderUseCase = saveGenderUseCase,
        _saveCategoryIdUseCase = saveCategoryIdUseCase,
        _loadCategoriesUseCase = loadCategoriesUseCase,
        _completeOnboardingUseCase = completeOnboardingUseCase,
        super(const OnboardingState()) {
    on<OnboardingStarted>(_onStarted);
    on<OnboardingAgeYearChanged>(_onAgeYearChanged);
    on<OnboardingAgeMonthChanged>(_onAgeMonthChanged);
    on<OnboardingAgeDayChanged>(_onAgeDayChanged);
    on<OnboardingAgeNextRequested>(_onAgeNextRequested);
    on<OnboardingGenderSelected>(_onGenderSelected);
    on<OnboardingCategorySelected>(_onCategorySelected);
    on<OnboardingInterestsNextRequested>(_onCategoryNextRequested);
    on<OnboardingSkipRequested>(_onSkipRequested);
    on<OnboardingNextRequested>(_onNextRequested);
    on<OnboardingNavigationCompleted>(_onNavigationCompleted);
  }

  final LoadOnboardingStateUseCase _loadOnboardingStateUseCase;
  final SaveBirthDateUseCase _saveBirthDateUseCase;
  final SaveGenderUseCase _saveGenderUseCase;
  final SaveCategoryIdUseCase _saveCategoryIdUseCase;
  final LoadCategoriesUseCase _loadCategoriesUseCase;
  final CompleteOnboardingUseCase _completeOnboardingUseCase;

  Future<void> _onStarted(
    OnboardingStarted _event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final OnboardingDraft draft = await _loadOnboardingStateUseCase(const NoParams());
      final List<Category> categories = await _loadCategoriesUseCase(const NoParams());
      emit(
        OnboardingState(
          birthYear: draft.birthYear,
          birthMonth: draft.birthMonth,
          birthDay: draft.birthDay,
          selectedGender: draft.selectedGender,
          categories: categories,
          selectedCategoryId: draft.selectedCategoryId,
          isLoading: false,
          isCompleted: false,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load onboarding state',
        ),
      );
    }
  }

  Future<void> _onAgeYearChanged(
    OnboardingAgeYearChanged event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(
      state.copyWith(
        birthYear: event.year,
        navigationTarget: null,
        errorMessage: null,
      ),
    );
  }

  Future<void> _onAgeMonthChanged(
    OnboardingAgeMonthChanged event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(
      state.copyWith(
        birthMonth: event.month,
        navigationTarget: null,
        errorMessage: null,
      ),
    );
  }

  Future<void> _onAgeDayChanged(
    OnboardingAgeDayChanged event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(
      state.copyWith(
        birthDay: event.day,
        navigationTarget: null,
        errorMessage: null,
      ),
    );
  }

  Future<void> _onAgeNextRequested(
    OnboardingAgeNextRequested _event,
    Emitter<OnboardingState> emit,
  ) async {
    if (!state.canContinueAge) {
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _saveBirthDateUseCase(
        SaveBirthDateParams(
          year: state.birthYear!,
          month: state.birthMonth!,
          day: state.birthDay!,
        ),
      );
      emit(
        state.copyWith(
          isLoading: false,
          navigationTarget: RouteNames.onboardingInterests,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to save birth date',
        ),
      );
    }
  }

  Future<void> _onGenderSelected(
    OnboardingGenderSelected event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(state.copyWith(selectedGender: event.gender, errorMessage: null));
    try {
      await _saveGenderUseCase(event.gender);
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Failed to save gender'));
    }
  }

  Future<void> _onCategorySelected(
    OnboardingCategorySelected event,
    Emitter<OnboardingState> emit,
  ) async {
    final String? newCategoryId = state.selectedCategoryId == event.categoryId
        ? null
        : event.categoryId;

    emit(
      state.copyWith(
        selectedCategoryId: newCategoryId,
        errorMessage: null,
      ),
    );

    try {
      await _saveCategoryIdUseCase(SaveCategoryIdParams(newCategoryId));
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Failed to save category'));
    }
  }

  Future<void> _onCategoryNextRequested(
    OnboardingInterestsNextRequested _event,
    Emitter<OnboardingState> emit,
  ) async {
    if (!state.canContinueCategory) {
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _completeOnboardingUseCase(const NoParams());
      emit(
        state.copyWith(
          isLoading: false,
          isCompleted: true,
          navigationTarget: RouteNames.register,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to complete onboarding',
        ),
      );
    }
  }

  Future<void> _onSkipRequested(
    OnboardingSkipRequested _event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _completeOnboardingUseCase(const NoParams());
      emit(
        state.copyWith(
          isLoading: false,
          isCompleted: true,
          navigationTarget: RouteNames.register,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to complete onboarding',
        ),
      );
    }
  }

  Future<void> _onNextRequested(
    OnboardingNextRequested _event,
    Emitter<OnboardingState> emit,
  ) async {
    if (!state.canContinueGender) {
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final GenderSelection selectedGender = state.selectedGender!;
      await _saveGenderUseCase(selectedGender);
      emit(
        state.copyWith(
          isLoading: false,
          navigationTarget: RouteNames.onboardingAge,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to save gender',
        ),
      );
    }
  }

  Future<void> _onNavigationCompleted(
    OnboardingNavigationCompleted _event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(state.copyWith(navigationTarget: null));
  }
}
