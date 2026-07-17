import '../../../../core/services/storage_service.dart';

enum AuthJourneyStage {
  auth,
  login,
  register,
  onboarding,
  onboardingAge,
  onboardingInterests,
  home,
}

extension AuthJourneyStageX on AuthJourneyStage {
  String get key => switch (this) {
    AuthJourneyStage.auth => 'auth',
    AuthJourneyStage.login => 'login',
    AuthJourneyStage.register => 'register',
    AuthJourneyStage.onboarding => 'onboarding',
    AuthJourneyStage.onboardingAge => 'onboarding_age',
    AuthJourneyStage.onboardingInterests => 'onboarding_interests',
    AuthJourneyStage.home => 'home',
  };
}

enum AuthSessionMode { guest, authenticated }

extension AuthSessionModeX on AuthSessionMode {
  String get key => switch (this) {
    AuthSessionMode.guest => 'guest',
    AuthSessionMode.authenticated => 'authenticated',
  };
}

AuthJourneyStage? authJourneyStageFromKey(String? key) {
  switch (key) {
    case 'auth':
      return AuthJourneyStage.auth;
    case 'login':
      return AuthJourneyStage.login;
    case 'register':
      return AuthJourneyStage.register;
    case 'onboarding':
      return AuthJourneyStage.onboarding;
    case 'onboarding_age':
      return AuthJourneyStage.onboardingAge;
    case 'onboarding_interests':
      return AuthJourneyStage.onboardingInterests;
    case 'home':
      return AuthJourneyStage.home;
  }

  return null;
}

AuthSessionMode? authSessionModeFromKey(String? key) {
  switch (key) {
    case 'guest':
      return AuthSessionMode.guest;
    case 'authenticated':
      return AuthSessionMode.authenticated;
  }

  return null;
}

abstract class AuthLocalDataSource {
  Future<Map<String, Object?>> getCachedUser();

  Future<bool> isAuthSeen();

  Future<void> markAuthSeen();

  Future<bool> isLoginSeen();

  Future<void> markLoginSeen();

  Future<bool> isRegisterSeen();

  Future<void> markRegisterSeen();

  Future<String?> getLastPhoneNumber();

  Future<String?> getLastPhoneIsoCode();

  Future<void> saveLastPhoneNumber(String phoneNumber, String isoCode);

  Future<bool> isNotificationPermissionSeen();

  Future<void> markNotificationPermissionSeen();

  Future<bool> isLocationPermissionSeen();

  Future<void> markLocationPermissionSeen();

  Future<AuthJourneyStage?> getCurrentStage();

  Future<AuthJourneyStage?> getPreviousStage();

  Future<void> saveJourneyStage(
    AuthJourneyStage stage, {
    AuthJourneyStage? previousStage,
  });

  Future<AuthSessionMode?> getSessionMode();

  Future<bool> isGuestSession();

  Future<bool> isAuthenticatedSession();

  Future<void> markGuestSession();

  Future<void> markAuthenticatedSession({
    String? accessToken,
    String? refreshToken,
    DateTime? accessTokenExpiration,
  });

  Future<String?> getAccessToken();

  Future<String?> getRefreshToken();

  Future<DateTime?> getAccessTokenExpiration();

  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  const AuthLocalDataSourceImpl(this._storageService);

  final StorageService _storageService;

  static const String _authSeenKey = 'auth_screen_seen';
  static const String _loginSeenKey = 'login_screen_seen';
  static const String _registerSeenKey = 'register_screen_seen';
  static const String _currentStageKey = 'journey_current_stage';
  static const String _previousStageKey = 'journey_previous_stage';
  static const String _sessionModeKey = 'auth_session_mode';
  static const String _accessTokenKey = 'auth_access_token';
  static const String _refreshTokenKey = 'auth_refresh_token';
  static const String _accessTokenExpirationKey =
      'auth_access_token_expiration';

  @override
  Future<Map<String, Object?>> getCachedUser() async {
    final AuthSessionMode? sessionMode = await getSessionMode();
    final DateTime? accessTokenExpiration = await getAccessTokenExpiration();

    return <String, Object?>{
      'sessionMode': sessionMode?.key,
      'accessToken': await getAccessToken(),
      'refreshToken': await getRefreshToken(),
      'accessTokenExpiration': accessTokenExpiration?.toIso8601String(),
    };
  }

  @override
  Future<bool> isAuthSeen() async {
    final bool? value = _storageService.getBool(_authSeenKey);
    return value ?? false;
  }

  @override
  Future<void> markAuthSeen() async {
    await saveJourneyStage(AuthJourneyStage.auth);
    await _storageService.setBool(_authSeenKey, true);
  }

  @override
  Future<bool> isLoginSeen() async {
    final bool? value = _storageService.getBool(_loginSeenKey);
    return value ?? false;
  }

  @override
  Future<void> markLoginSeen() async {
    await saveJourneyStage(AuthJourneyStage.login);
    await _storageService.setBool(_loginSeenKey, true);
  }

  @override
  Future<bool> isRegisterSeen() async {
    final bool? value = _storageService.getBool(_registerSeenKey);
    return value ?? false;
  }

  @override
  Future<void> markRegisterSeen() async {
    await saveJourneyStage(AuthJourneyStage.register);
    await _storageService.setBool(_registerSeenKey, true);
  }

  @override
  Future<String?> getLastPhoneNumber() async {
    return _storageService.getString(_lastPhoneNumberKey);
  }

  @override
  Future<String?> getLastPhoneIsoCode() async {
    return _storageService.getString(_lastPhoneIsoCodeKey);
  }

  @override
  Future<void> saveLastPhoneNumber(String phoneNumber, String isoCode) async {
    await _storageService.setString(_lastPhoneNumberKey, phoneNumber);
    await _storageService.setString(_lastPhoneIsoCodeKey, isoCode);
  }

  static const String _notificationPermissionSeenKey =
      'notification_permission_seen';
  static const String _locationPermissionSeenKey = 'location_permission_seen';
  static const String _lastPhoneNumberKey = 'last_phone_number';
  static const String _lastPhoneIsoCodeKey = 'last_phone_iso_code';

  @override
  Future<bool> isNotificationPermissionSeen() async {
    final bool? value = _storageService.getBool(_notificationPermissionSeenKey);
    return value ?? false;
  }

  @override
  Future<void> markNotificationPermissionSeen() async {
    await _storageService.setBool(_notificationPermissionSeenKey, true);
  }

  @override
  Future<bool> isLocationPermissionSeen() async {
    final bool? value = _storageService.getBool(_locationPermissionSeenKey);
    return value ?? false;
  }

  @override
  Future<void> markLocationPermissionSeen() async {
    await _storageService.setBool(_locationPermissionSeenKey, true);
  }

  @override
  Future<AuthJourneyStage?> getCurrentStage() async {
    return authJourneyStageFromKey(_storageService.getString(_currentStageKey));
  }

  @override
  Future<AuthJourneyStage?> getPreviousStage() async {
    return authJourneyStageFromKey(
      _storageService.getString(_previousStageKey),
    );
  }

  @override
  Future<void> saveJourneyStage(
    AuthJourneyStage stage, {
    AuthJourneyStage? previousStage,
  }) async {
    final AuthJourneyStage? currentStage = await getCurrentStage();
    if (previousStage != null) {
      await _storageService.setString(_previousStageKey, previousStage.key);
    } else if (currentStage != null && currentStage != stage) {
      await _storageService.setString(_previousStageKey, currentStage.key);
    }

    await _storageService.setString(_currentStageKey, stage.key);

    if (stage == AuthJourneyStage.home) {
      await _storageService.remove(_authSeenKey);
    }
  }

  @override
  Future<AuthSessionMode?> getSessionMode() async {
    return authSessionModeFromKey(_storageService.getString(_sessionModeKey));
  }

  @override
  Future<bool> isGuestSession() async {
    return (await getSessionMode()) == AuthSessionMode.guest;
  }

  @override
  Future<bool> isAuthenticatedSession() async {
    return (await getSessionMode()) == AuthSessionMode.authenticated;
  }

  @override
  Future<void> markGuestSession() async {
    await _storageService.setString(_sessionModeKey, AuthSessionMode.guest.key);
    await _storageService.remove(_accessTokenKey);
    await _storageService.remove(_refreshTokenKey);
    await saveJourneyStage(AuthJourneyStage.home);
  }

  @override
  Future<void> markAuthenticatedSession({
    String? accessToken,
    String? refreshToken,
    DateTime? accessTokenExpiration,
  }) async {
    await _storageService.setString(
      _sessionModeKey,
      AuthSessionMode.authenticated.key,
    );

    if (accessToken != null) {
      await _storageService.setString(_accessTokenKey, accessToken);
    }
    if (refreshToken != null) {
      await _storageService.setString(_refreshTokenKey, refreshToken);
    }
    if (accessTokenExpiration != null) {
      await _storageService.setString(
        _accessTokenExpirationKey,
        accessTokenExpiration.toIso8601String(),
      );
    }

    await saveJourneyStage(AuthJourneyStage.home);
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
  Future<DateTime?> getAccessTokenExpiration() async {
    final String? value = _storageService.getString(_accessTokenExpirationKey);
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  @override
  Future<void> clearSession() async {
    await _storageService.remove(_sessionModeKey);
    await _storageService.remove(_accessTokenKey);
    await _storageService.remove(_refreshTokenKey);
    await _storageService.remove(_accessTokenExpirationKey);
    await saveJourneyStage(AuthJourneyStage.auth);
  }
}
