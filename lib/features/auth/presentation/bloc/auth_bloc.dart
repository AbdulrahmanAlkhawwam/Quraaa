import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error_monitoring/user_context_provider.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/user_local_datasource.dart';
import '../../data/models/user_model.dart';
import '../../domain/entities/user.dart';
import '../../domain/use_cases/login_use_case.dart';
import '../../domain/use_cases/register_use_case.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required AuthLocalDataSource authJourney,
    required UserLocalDataSource userCache,
    required UserContextProvider userContext,
  }) : _loginUseCase = loginUseCase,
       _registerUseCase = registerUseCase,
       _authJourney = authJourney,
       _userCache = userCache,
       _userContext = userContext,
       super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
  }

  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final AuthLocalDataSource _authJourney;
  final UserLocalDataSource _userCache;
  final UserContextProvider _userContext;

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _loginUseCase(
        LoginParams(
          phoneNumber: event.phoneNumber,
          password: event.password,
        ),
      );

      await _authJourney.markAuthenticatedSession(
        accessToken: user.accessToken,
        refreshToken: user.refreshToken,
      );
      await _userCache.saveUser(_toModel(user));
      await _userContext.setUser(
        id: user.phoneNumber ?? event.phoneNumber,
        name: user.fullName.isNotEmpty ? user.fullName : event.phoneNumber,
        phone: user.phoneNumber ?? event.phoneNumber,
        subscriptionStatus: 'active',
      );
      emit(const AuthSuccess());
    } catch (error) {
      emit(AuthError(error));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final tokens = await _registerUseCase(
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

      await _authJourney.markAuthenticatedSession(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      await _userCache.saveUser(_toModel(tokens));
      await _userContext.setUser(
        id: event.phoneNumber ?? '',
        name: <String?>[
          event.firstName,
          event.lastName,
        ].where((s) => s != null && s.isNotEmpty).join(' '),
        phone: event.phoneNumber,
        subscriptionStatus: 'active',
      );
      emit(const AuthSuccess());
    } catch (error) {
      emit(AuthError(error));
    }
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
