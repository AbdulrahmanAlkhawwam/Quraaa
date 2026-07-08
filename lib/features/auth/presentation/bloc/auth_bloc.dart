import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import '../../../../core/error_monitoring/user_context_provider.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/user_local_datasource.dart';
import '../../data/models/user_model.dart';
import '../../domain/entities/user.dart';
import '../../domain/use_cases/login_use_case.dart';
import '../../domain/use_cases/register_use_case.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this._loginUseCase,
    required this._registerUseCase,
    required this._authJourney,
    required this._userCache,
    required this._userContext,
  }) : super(const AuthState()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthStarted>(_onStarted);
    on<AuthOnboardingRequested>(_onOnboardingRequested);
    on<AuthLoginRequestedFromAuth>(_onLoginRequestedFromAuth);
  }

  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final AuthLocalDataSource _authJourney;
  final UserLocalDataSource _userCache;
  final UserContextProvider _userContext;

  static const String _subscriptionStatus = 'active';

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final response = await _loginUseCase(
      LoginParams(phoneNumber: event.phoneNumber, password: event.password),
    );
    await response.fold(
      (failure) async => emit(
        state.copyWith(
          status: AuthStatus.error,
          error: failure.cause ?? failure.message,
        ),
      ),
      (user) async {
        final phone = user.phoneNumber ?? event.phoneNumber;
        await _onAuthenticated(
          user,
          id: phone,
          name: user.fullName.isNotEmpty ? user.fullName : phone,
          phone: phone,
        );
        emit(state.copyWith(status: AuthStatus.success));
      },
    );
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final response = await _registerUseCase(
      RegisterParams(
        firstName: event.firstName,
        lastName: event.lastName,
        phoneNumber: event.phoneNumber,
        password: event.password,
        gender: event.gender,
        dateOfBirth: event.dateOfBirth,
        categoryIds: event.categoryIds,
      ),
    );
    await response.fold(
      (failure) async => emit(
        state.copyWith(
          status: AuthStatus.error,
          error: failure.cause ?? failure.message,
        ),
      ),
      (user) async {
        await _onAuthenticated(
          user,
          id: event.phoneNumber ?? '',
          name: [
            event.firstName,
            event.lastName,
          ].whereType<String>().where((s) => s.isNotEmpty).join(' '),
          phone: event.phoneNumber,
        );
        emit(state.copyWith(status: AuthStatus.success));
      },
    );
  }

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    await _authJourney.markAuthSeen();
    emit(const AuthState());
  }

  Future<void> _onOnboardingRequested(
    AuthOnboardingRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AuthStatus.navigationLoading,
        destination: AuthNavigationDestination.onboarding,
      ),
    );
    await _authJourney.saveJourneyStage(
      AuthJourneyStage.onboarding,
      previousStage: AuthJourneyStage.auth,
    );
    emit(const AuthState(status: AuthStatus.navigateToOnboarding));
  }

  Future<void> _onLoginRequestedFromAuth(
    AuthLoginRequestedFromAuth event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AuthStatus.navigationLoading,
        destination: AuthNavigationDestination.login,
      ),
    );
    await _authJourney.saveJourneyStage(
      AuthJourneyStage.login,
      previousStage: AuthJourneyStage.auth,
    );
    emit(const AuthState(status: AuthStatus.navigateToLogin));
  }

  /// Persists the authenticated session, caches the user, and reports the
  /// user context after a successful login or registration.
  Future<void> _onAuthenticated(
    User user, {
    required String id,
    required String name,
    required String? phone,
  }) async {
    await _authJourney.markAuthenticatedSession(
      accessToken: user.accessToken,
      refreshToken: user.refreshToken,
      accessTokenExpiration: user.accessTokenExpiration,
    );
    await _userCache.saveUser(_toModel(user));
    await _userContext.setUser(
      id: id,
      name: name,
      phone: phone,
      subscriptionStatus: _subscriptionStatus,
    );
  }

  /// Converts the domain entity returned by the use cases into a [UserModel]
  /// so it can be cached by the local data source.
  UserModel _toModel(User user) {
    if (user is UserModel) {
      return user;
    }
    return UserModel(
      id: user.id,
      firstName: user.firstName,
      lastName: user.lastName,
      phoneNumber: user.phoneNumber,
      country: user.country,
      password: user.password,
      interests: user.interests,
      birthday: user.birthday,
      gender: user.gender,
      location: user.location,
      language: user.language,
      deviceAndroidVersion: user.deviceAndroidVersion,
      accessToken: user.accessToken,
      refreshToken: user.refreshToken,
      accessTokenExpiration: user.accessTokenExpiration,
    );
  }
}
