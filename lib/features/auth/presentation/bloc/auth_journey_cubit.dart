import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import '../../data/datasources/auth_local_datasource.dart';

@immutable
class AuthJourneyState {
  const AuthJourneyState({this.isSaving = false});

  final bool isSaving;

  AuthJourneyState copyWith({bool? isSaving}) {
    return AuthJourneyState(isSaving: isSaving ?? this.isSaving);
  }
}

class AuthJourneyCubit extends Cubit<AuthJourneyState> {
  AuthJourneyCubit({required AuthLocalDataSource authJourney})
      : _authJourney = authJourney,
        super(const AuthJourneyState());

  final AuthLocalDataSource _authJourney;

  Future<void> enterOnboarding() {
    return _saveStage(AuthJourneyStage.onboarding);
  }

  Future<void> enterOnboardingAge() {
    return _saveStage(AuthJourneyStage.onboardingAge);
  }

  Future<void> enterOnboardingInterests() {
    return _saveStage(AuthJourneyStage.onboardingInterests);
  }

  Future<void> moveFromOnboardingToAuth() {
    return _saveStage(
      AuthJourneyStage.auth,
      previousStage: AuthJourneyStage.onboarding,
    );
  }

  Future<void> moveFromOnboardingToRegister() {
    return _saveStage(
      AuthJourneyStage.register,
      previousStage: AuthJourneyStage.onboarding,
    );
  }

  Future<void> moveFromAgeToOnboarding() {
    return _saveStage(
      AuthJourneyStage.onboarding,
      previousStage: AuthJourneyStage.onboardingAge,
    );
  }

  Future<void> moveFromAgeToRegister() {
    return _saveStage(
      AuthJourneyStage.register,
      previousStage: AuthJourneyStage.onboardingAge,
    );
  }

  Future<void> moveFromInterestsToAge() {
    return _saveStage(
      AuthJourneyStage.onboardingAge,
      previousStage: AuthJourneyStage.onboardingInterests,
    );
  }

  Future<void> moveFromInterestsToRegister() {
    return _saveStage(
      AuthJourneyStage.register,
      previousStage: AuthJourneyStage.onboardingInterests,
    );
  }

  Future<void> _saveStage(
    AuthJourneyStage stage, {
    AuthJourneyStage? previousStage,
  }) async {
    emit(state.copyWith(isSaving: true));
    try {
      await _authJourney.saveJourneyStage(stage, previousStage: previousStage);
    } finally {
      emit(state.copyWith(isSaving: false));
    }
  }
}
