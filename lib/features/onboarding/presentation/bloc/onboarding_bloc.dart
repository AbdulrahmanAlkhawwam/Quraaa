import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routes/route_names.dart';
import '../../domain/entities/gender_selection.dart';
import '../../domain/entities/interest_selection.dart';
import '../viewmodels/onboarding_view_model.dart';

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

final class OnboardingInterestToggled extends OnboardingEvent {
  const OnboardingInterestToggled(this.interest);

  final InterestSelection interest;
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

class OnboardingState {
  const OnboardingState({
    this.birthYear,
    this.birthMonth,
    this.birthDay,
    this.selectedGender,
    this.selectedInterests = const <InterestSelection>[],
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
  final List<InterestSelection> selectedInterests;
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

  bool get hasInterests => selectedInterests.isNotEmpty;

  bool get canContinueInterests =>
      hasInterests && !isLoading && !isCompleted;

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
    Object? selectedInterests = _unset,
    bool? isLoading,
    bool? isCompleted,
    Object? navigationTarget = _unset,
    String? errorMessage,
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
      selectedInterests: identical(selectedInterests, _unset)
          ? this.selectedInterests
          : List<InterestSelection>.unmodifiable(
              selectedInterests as List<InterestSelection>,
            ),
      isLoading: isLoading ?? this.isLoading,
      isCompleted: isCompleted ?? this.isCompleted,
      navigationTarget: identical(navigationTarget, _unset)
          ? this.navigationTarget
          : navigationTarget as String?,
      errorMessage: errorMessage,
    );
  }
}

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc(this._viewModel) : super(const OnboardingState()) {
    on<OnboardingStarted>(_onStarted);
    on<OnboardingAgeYearChanged>(_onAgeYearChanged);
    on<OnboardingAgeMonthChanged>(_onAgeMonthChanged);
    on<OnboardingAgeDayChanged>(_onAgeDayChanged);
    on<OnboardingAgeNextRequested>(_onAgeNextRequested);
    on<OnboardingGenderSelected>(_onGenderSelected);
    on<OnboardingInterestToggled>(_onInterestToggled);
    on<OnboardingInterestsNextRequested>(_onInterestsNextRequested);
    on<OnboardingSkipRequested>(_onSkipRequested);
    on<OnboardingNextRequested>(_onNextRequested);
  }

  final OnboardingViewModel _viewModel;

  Future<void> _onStarted(
    OnboardingStarted _event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final draft = await _viewModel.loadState();
      emit(
        OnboardingState(
          birthYear: draft.birthYear,
          birthMonth: draft.birthMonth,
          birthDay: draft.birthDay,
          selectedGender: draft.selectedGender,
          selectedInterests: draft.selectedInterests,
          isLoading: false,
          isCompleted: draft.completed,
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
      await _viewModel.saveBirthDate(
        year: state.birthYear!,
        month: state.birthMonth!,
        day: state.birthDay!,
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
      await _viewModel.selectGender(event.gender);
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Failed to save gender'));
    }
  }

  Future<void> _onInterestToggled(
    OnboardingInterestToggled event,
    Emitter<OnboardingState> emit,
  ) async {
    final List<InterestSelection> updatedInterests =
        List<InterestSelection>.from(state.selectedInterests);
    if (updatedInterests.contains(event.interest)) {
      updatedInterests.remove(event.interest);
    } else {
      updatedInterests.add(event.interest);
    }

    emit(
      state.copyWith(
        selectedInterests: List<InterestSelection>.unmodifiable(updatedInterests),
        errorMessage: null,
      ),
    );

    try {
      await _viewModel.saveInterests(updatedInterests);
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Failed to save interests'));
    }
  }

  Future<void> _onInterestsNextRequested(
    OnboardingInterestsNextRequested _event,
    Emitter<OnboardingState> emit,
  ) async {
    if (!state.canContinueInterests) {
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _viewModel.completeOnboarding();
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
      await _viewModel.completeOnboarding();
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
      await _viewModel.selectGender(selectedGender);
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
}
