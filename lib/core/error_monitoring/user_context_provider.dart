import 'package:flutter/widgets.dart';

import '../services/storage_service.dart';

class UserContextProvider {
  UserContextProvider(this._storageService);

  final StorageService _storageService;

  static const String _userIdKey = 'monitoring_user_id';
  static const String _userNameKey = 'monitoring_user_name';
  static const String _userEmailKey = 'monitoring_user_email';
  static const String _userPhoneKey = 'monitoring_user_phone';
  static const String _subscriptionStatusKey = 'monitoring_subscription_status';
  static const String _languageKey = 'monitoring_language';
  static const String _lastActionKey = 'monitoring_last_action';

  UserContextSnapshot _snapshot = const UserContextSnapshot();

  UserContextSnapshot get snapshot => _snapshot;

  Future<void> initialize() async {
    try {
      _snapshot = UserContextSnapshot(
        userId: _storageService.getString(_userIdKey),
        userName: _storageService.getString(_userNameKey),
        userEmail: _storageService.getString(_userEmailKey),
        userPhone: _storageService.getString(_userPhoneKey),
        subscriptionStatus:
            _storageService.getString(_subscriptionStatusKey) ?? 'unknown',
        language:
            _storageService.getString(_languageKey) ?? WidgetsBinding.instance.platformDispatcher.locale.toLanguageTag(),
        lastUserAction: _storageService.getString(_lastActionKey),
      );
    } catch (_) {
      _snapshot = UserContextSnapshot(
        subscriptionStatus: 'unknown',
        language: WidgetsBinding.instance.platformDispatcher.locale.toLanguageTag(),
      );
    }
  }

  Future<void> setUser({
    required String id,
    String? name,
    String? email,
    String? phone,
    String? subscriptionStatus,
  }) async {
    _snapshot = _snapshot.copyWith(
      userId: id,
      userName: name,
      userEmail: email,
      userPhone: phone,
      subscriptionStatus: subscriptionStatus ?? 'active',
    );

    await _persistUser();
  }

  Future<void> clearUser() async {
    _snapshot = const UserContextSnapshot(
      subscriptionStatus: 'guest',
    );

    await _storageService.remove(_userIdKey);
    await _storageService.remove(_userNameKey);
    await _storageService.remove(_userEmailKey);
    await _storageService.remove(_userPhoneKey);
    await _storageService.setString(_subscriptionStatusKey, 'guest');
    await _storageService.remove(_lastActionKey);
    await _storageService.remove(_languageKey);
  }

  Future<void> setSubscriptionStatus(String subscriptionStatus) async {
    _snapshot = _snapshot.copyWith(subscriptionStatus: subscriptionStatus);
    await _storageService.setString(_subscriptionStatusKey, subscriptionStatus);
  }

  Future<void> setLanguage(String language) async {
    _snapshot = _snapshot.copyWith(language: language);
    await _storageService.setString(_languageKey, language);
  }

  Future<void> recordAction(String action) async {
    final String normalized = action.trim();
    if (normalized.isEmpty) {
      return;
    }

    _snapshot = _snapshot.copyWith(lastUserAction: normalized);
    await _storageService.setString(_lastActionKey, normalized);
  }

  Future<void> _persistUser() async {
    await _persistValue(_userIdKey, _snapshot.userId);
    await _persistValue(_userNameKey, _snapshot.userName);
    await _persistValue(_userEmailKey, _snapshot.userEmail);
    await _persistValue(_userPhoneKey, _snapshot.userPhone);
    await _persistValue(_subscriptionStatusKey, _snapshot.subscriptionStatus);
  }

  Future<void> _persistValue(String key, String? value) async {
    if (value == null || value.trim().isEmpty) {
      await _storageService.remove(key);
      return;
    }

    await _storageService.setString(key, value);
  }
}

class UserContextSnapshot {
  const UserContextSnapshot({
    this.userId,
    this.userName,
    this.userEmail,
    this.userPhone,
    this.subscriptionStatus,
    this.language,
    this.lastUserAction,
  });

  final String? userId;
  final String? userName;
  final String? userEmail;
  final String? userPhone;
  final String? subscriptionStatus;
  final String? language;
  final String? lastUserAction;

  UserContextSnapshot copyWith({
    String? userId,
    String? userName,
    String? userEmail,
    String? userPhone,
    String? subscriptionStatus,
    String? language,
    String? lastUserAction,
  }) {
    return UserContextSnapshot(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      language: language ?? this.language,
      lastUserAction: lastUserAction ?? this.lastUserAction,
    );
  }
}
