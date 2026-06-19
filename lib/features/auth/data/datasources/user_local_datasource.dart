import '../../../../core/domain/entities/location.dart';
import '../../../../core/services/storage_service.dart';

import '../../domain/entities/user.dart';
import '../mappers/user_mapper.dart';
import '../models/user_model.dart';

/// {@template user_local_data_source}
/// Local cache for the currently authenticated user profile.
///
/// Stores the whole user object as a JSON blob under a single key, plus
/// dedicated keys for tokens so they can be read quickly without parsing
/// the entire payload.
/// {@endtemplate}
abstract class UserLocalDataSource {
  /// Persists the entire user profile.
  Future<void> saveUser(UserModel user);

  /// Retrieves the cached user, or `null` if none is stored.
  Future<UserModel?> getUser();

  /// Clears the cached user profile (and tokens).
  Future<void> clearUser();

  /// Returns `true` when a user object exists in cache.
  Future<bool> hasUser();

  /// Updates only the tokens (useful after a token refresh).
  Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
    DateTime? accessTokenExpiration,
  });

  /// Returns the stored access token (or `null`).
  Future<String?> getAccessToken();

  /// Returns the stored refresh token (or `null`).
  Future<String?> getRefreshToken();

  /// Partial update of profile fields without overwriting the whole object.
  Future<UserModel?> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? country,
    String? birthday,
    String? gender,
    List<String>? interests,
    Location? location,
    String? language,
    String? deviceAndroidVersion,
  });
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  const UserLocalDataSourceImpl(this._storageService);

  final StorageService _storageService;

  static const String _userKey = 'cached_user_profile';
  static const String _accessTokenKey = 'user_access_token';
  static const String _refreshTokenKey = 'user_refresh_token';
  static const String _tokenExpirationKey = 'user_access_token_expiration';

  @override
  Future<void> saveUser(UserModel user) async {
    await _storageService.setString(_userKey, user.toRawJson());

    if (user.accessToken != null && user.accessToken!.isNotEmpty) {
      await _storageService.setString(_accessTokenKey, user.accessToken!);
    }
    if (user.refreshToken != null && user.refreshToken!.isNotEmpty) {
      await _storageService.setString(_refreshTokenKey, user.refreshToken!);
    }
    if (user.accessTokenExpiration != null) {
      await _storageService.setString(
        _tokenExpirationKey,
        user.accessTokenExpiration!.toIso8601String(),
      );
    }
  }

  @override
  Future<UserModel?> getUser() async {
    final raw = _storageService.getString(_userKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      return UserMapper.fromRawJson(raw);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearUser() async {
    await _storageService.remove(_userKey);
    await _storageService.remove(_accessTokenKey);
    await _storageService.remove(_refreshTokenKey);
    await _storageService.remove(_tokenExpirationKey);
  }

  @override
  Future<bool> hasUser() async {
    return _storageService.contains(_userKey);
  }

  @override
  Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
    DateTime? accessTokenExpiration,
  }) async {
    await _storageService.setString(_accessTokenKey, accessToken);
    await _storageService.setString(_refreshTokenKey, refreshToken);

    if (accessTokenExpiration != null) {
      await _storageService.setString(
        _tokenExpirationKey,
        accessTokenExpiration.toIso8601String(),
      );
    }

    // Also update the embedded tokens inside the full user blob so it stays
    // in sync (best-effort: if no user exists, we only store the tokens).
    final user = await getUser();
    if (user != null) {
      final updated = user.copyWith(
        accessToken: accessToken,
        refreshToken: refreshToken,
        accessTokenExpiration: accessTokenExpiration,
      );
      await _storageService.setString(_userKey, updated.toRawJson());
    }
  }

  @override
  Future<String?> getAccessToken() async {
    return _storageService.getString(_accessTokenKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    return _storageService.getString(_refreshTokenKey);
  }

  @override
  Future<UserModel?> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? country,
    String? birthday,
    String? gender,
    List<String>? interests,
    Location? location,
    String? language,
    String? deviceAndroidVersion,
  }) async {
    final user = await getUser();
    if (user == null) return null;

    final updated = user.copyWith(
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      country: country,
      birthday: birthday,
      gender: gender,
      interests: interests,
      location: location,
      language: language,
      deviceAndroidVersion: deviceAndroidVersion,
    );

    await saveUser(updated);
    return updated;
  }
}
