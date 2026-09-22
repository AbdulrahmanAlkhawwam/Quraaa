import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_local_data_source.dart';
import '../data_sources/auth_remote_data_source.dart';
import '../mappers/auth_mapper.dart';
import '../models/user_model.dart';
import '../services/auth_session_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._sessionService,
  );

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final AuthSessionService _sessionService;

  @override
  FutureEither<User> login({
    required String phoneNumber,
    required String password,
  }) {
    return _guard(() async {
      final Map<String, Object?> response = await _remoteDataSource.login(
        phoneNumber: phoneNumber,
        password: password,
      );
      return _signIn(AuthMapper.fromJson(response), phoneNumber: phoneNumber);
    });
  }

  @override
  FutureEither<User> register({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? password,
    int? gender,
    String? dateOfBirth,
    List<String>? categoryIds,
  }) {
    return _guard(() async {
      final Map<String, Object?> response = await _remoteDataSource.register(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        password: password,
        gender: gender,
        dateOfBirth: dateOfBirth,
        categoryIds: categoryIds,
      );
      return AuthMapper.fromJson(response).toEntity();
    });
  }

  @override
  FutureEither<String> refreshSession() {
    return _guard(() async {
      final String? refreshToken = await _localDataSource.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw const _SessionRefreshUnavailable('No refresh token stored.');
      }
      final Map<String, Object?> response = await _remoteDataSource
          .refreshToken(refreshToken: refreshToken);
      final String? accessToken = await _sessionService
          .refreshAuthenticatedSession(
            AuthMapper.fromJson(response),
            previousRefreshToken: refreshToken,
          );
      if (accessToken == null) {
        throw const _SessionRefreshUnavailable(
          'Refresh response carried no access token.',
        );
      }
      return accessToken;
    });
  }

  @override
  FutureEither<bool> logout() {
    return _guard(() async {
      final String? refreshToken = await _localDataSource.getRefreshToken();
      await _remoteDataSource.logout(refreshToken: refreshToken);
      return true;
    });
  }

  @override
  FutureEither<User> verifyOtp({
    required String phoneNumber,
    required String code,
  }) {
    return _guard(() async {
      final Map<String, Object?> response = await _remoteDataSource.verifyOtp(
        phoneNumber: phoneNumber,
        code: code,
      );
      return _signIn(AuthMapper.fromJson(response), phoneNumber: phoneNumber);
    });
  }

  @override
  FutureEither<bool> sendOtp({required String phoneNumber}) {
    return _guard(() async {
      await _remoteDataSource.sendOtp(phoneNumber: phoneNumber);
      return true;
    });
  }

  @override
  FutureEither<bool> forgotPassword({required String phoneNumber}) {
    return _guard(() async {
      await _remoteDataSource.forgotPassword(phoneNumber: phoneNumber);
      return true;
    });
  }

  @override
  FutureEither<bool> resetPassword({
    required String phoneNumber,
    required String code,
    required String newPassword,
  }) {
    return _guard(() async {
      await _remoteDataSource.resetPassword(
        phoneNumber: phoneNumber,
        code: code,
        newPassword: newPassword,
      );
      return true;
    });
  }

  @override
  FutureEither<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) {
    return _guard(() async {
      await _remoteDataSource.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      return true;
    });
  }

  /// Persists the session for a freshly signed-in user, then hands back the
  /// token-free entity. The phone number the user typed is the fallback
  /// identity when the backend omits id or phone.
  Future<User> _signIn(UserModel model, {required String phoneNumber}) async {
    await _sessionService.completeAuthenticatedSession(
      model,
      fallbackId: phoneNumber,
      fallbackPhone: phoneNumber,
    );
    return model.toEntity();
  }

  /// One try/catch for every call: anything thrown below the domain boundary
  /// becomes a typed [Failure] via [ErrorMapper].
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() body) async {
    try {
      return Right(await body());
    } on _SessionRefreshUnavailable catch (e) {
      return Left(TokenExpiredFailure(message: e.message));
    } catch (error) {
      return Left(ErrorMapper.map(error));
    }
  }
}

class _SessionRefreshUnavailable implements Exception {
  const _SessionRefreshUnavailable(this.message);

  final String message;
}
