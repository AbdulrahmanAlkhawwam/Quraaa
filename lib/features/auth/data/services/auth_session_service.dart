import '../../../../core/error_monitoring/user_context_provider.dart';
import '../../domain/entities/user.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/user_local_datasource.dart';
import '../models/user_model.dart';

/// Finalizes a successful authentication operation as one local transaction.
///
/// The session marker is written last so startup routing cannot treat a
/// partially cached login as authenticated.
class AuthSessionService {
  const AuthSessionService({
    required AuthLocalDataSource authLocalDataSource,
    required UserLocalDataSource userLocalDataSource,
    required UserContextProvider userContextProvider,
    Future<void> Function()? afterAuthentication,
    Future<void> Function()? afterSessionExpired,
  }) : _authLocalDataSource = authLocalDataSource,
       _userLocalDataSource = userLocalDataSource,
       _userContextProvider = userContextProvider,
       _afterAuthentication = afterAuthentication,
       _afterSessionExpired = afterSessionExpired;

  final AuthLocalDataSource _authLocalDataSource;
  final UserLocalDataSource _userLocalDataSource;
  final UserContextProvider _userContextProvider;
  final Future<void> Function()? _afterAuthentication;
  final Future<void> Function()? _afterSessionExpired;

  Future<void> completeAuthenticatedSession(
    User user, {
    required String fallbackId,
    String? fallbackName,
    String? fallbackPhone,
  }) async {
    final String? phone =
        _nonEmpty(user.phoneNumber) ?? _nonEmpty(fallbackPhone);
    final String id =
        _nonEmpty(user.id) ?? phone ?? _nonEmpty(fallbackId) ?? 'authenticated';
    final String? name =
        _nonEmpty(user.fullName) ?? _nonEmpty(fallbackName) ?? phone;

    try {
      await _userLocalDataSource.saveUser(_toModel(user, phone: phone));
      await _userContextProvider.setUser(
        id: id,
        name: name,
        phone: phone,
        subscriptionStatus: 'active',
      );
      await _authLocalDataSource.markAuthenticatedSession(
        accessToken: user.accessToken,
        refreshToken: user.refreshToken,
        accessTokenExpiration: user.accessTokenExpiration,
      );
      try {
        await _afterAuthentication?.call();
      } catch (_) {
        // Profile bootstrapping must never turn a valid login into a failure.
      }
    } catch (_) {
      await _rollbackPartialSession();
      rethrow;
    }
  }

  /// Clears only authenticated-user data after the backend rejects a session.
  Future<void> expireAuthenticatedSession() async {
    await _rollbackPartialSession();
    try {
      await _afterSessionExpired?.call();
    } catch (_) {
      // A secondary cache must not prevent routing back to authentication.
    }
  }

  /// Persists rotated tokens after a successful refresh operation.
  Future<String?> refreshAuthenticatedSession(
    User user, {
    required String previousRefreshToken,
  }) async {
    final String? accessToken = _nonEmpty(user.accessToken);
    if (accessToken == null) {
      return null;
    }

    final String refreshToken =
        _nonEmpty(user.refreshToken) ?? previousRefreshToken;
    await _userLocalDataSource.updateTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      accessTokenExpiration: user.accessTokenExpiration,
    );
    await _authLocalDataSource.markAuthenticatedSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      accessTokenExpiration: user.accessTokenExpiration,
    );
    return accessToken;
  }

  Future<void> _rollbackPartialSession() async {
    try {
      await _userLocalDataSource.clearUser();
    } catch (_) {}
    try {
      await _userContextProvider.clearUser();
    } catch (_) {}
    try {
      await _authLocalDataSource.clearSession();
    } catch (_) {}
  }

  UserModel _toModel(User user, {required String? phone}) {
    if (user is UserModel && user.phoneNumber == phone) {
      return user;
    }
    return UserModel(
      id: user.id,
      firstName: user.firstName,
      lastName: user.lastName,
      phoneNumber: phone,
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

  String? _nonEmpty(String? value) {
    final String normalized = value?.trim() ?? '';
    return normalized.isEmpty ? null : normalized;
  }
}
