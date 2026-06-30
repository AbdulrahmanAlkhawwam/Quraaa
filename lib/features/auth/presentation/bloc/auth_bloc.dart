import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error_monitoring/user_context_provider.dart';
import '../../data/datasources/local/auth_journey_local_data_source.dart';
import '../../domain/repositories/auth_repository.dart';

sealed class AuthEvent {
  const AuthEvent();
}

final class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({
    required this.phoneNumber,
    required this.password,
  });

  final String phoneNumber;
  final String password;
}

final class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.password,
    required this.gender,
    required this.dateOfBirth,
    required this.interests,
  });

  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String password;
  final int gender;
  final String dateOfBirth;
  final List<String> interests;
}

sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthSuccess extends AuthState {
  const AuthSuccess();
}

final class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required AuthRepository authRepository,
    required AuthJourneyLocalDataSource authJourney,
    required UserContextProvider userContext,
  })  : _authRepository = authRepository,
        _authJourney = authJourney,
        _userContext = userContext,
        super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
  }

  final AuthRepository _authRepository;
  final AuthJourneyLocalDataSource _authJourney;
  final UserContextProvider _userContext;

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authJourney.markAuthenticatedSession();
      await _userContext.setUser(
        id: event.phoneNumber,
        name: event.phoneNumber,
        phone: event.phoneNumber,
        subscriptionStatus: 'active',
      );
      emit(const AuthSuccess());
    } catch (error) {
      emit(AuthError(error.toString()));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final tokens = await _authRepository.register(
        firstName: event.firstName,
        lastName: event.lastName,
        phoneNumber: event.phoneNumber,
        password: event.password,
        gender: event.gender,
        dateOfBirth: event.dateOfBirth,
        interests: event.interests,
      );

      await _authJourney.markAuthenticatedSession(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      await _userContext.setUser(
        id: event.phoneNumber,
        name: '${event.firstName} ${event.lastName}'.trim(),
        phone: event.phoneNumber,
        subscriptionStatus: 'active',
      );
      emit(const AuthSuccess());
    } catch (error) {
      emit(AuthError(error.toString()));
    }
  }
}
