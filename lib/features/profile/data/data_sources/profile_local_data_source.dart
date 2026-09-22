import 'dart:convert';

import '../../../../core/services/storage_service.dart';
import '../models/profile_model.dart';

/// {@template profile_local_data_source}
/// Local cache for the authenticated user's profile returned by
/// `/api/Profile/me`.
///
/// The latest successful response is stored as a JSON blob so the profile
/// screen can still show data while the device is offline.
/// {@endtemplate}
abstract class ProfileLocalDataSource {
  /// Persists the profile returned by the backend.
  Future<void> cacheProfile(ProfileModel profile);

  /// Returns the cached profile, or `null` if none is stored.
  Future<ProfileModel?> getCachedProfile();

  /// Clears the cached profile.
  Future<void> clearCachedProfile();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  const ProfileLocalDataSourceImpl(this._storageService);

  final StorageService _storageService;

  static const String _cachedProfileKey = 'cached_profile_me';

  @override
  Future<void> cacheProfile(ProfileModel profile) async {
    final String raw = jsonEncode(profile.toJson());
    await _storageService.setString(_cachedProfileKey, raw);
  }

  @override
  Future<ProfileModel?> getCachedProfile() async {
    final String? raw = _storageService.getString(_cachedProfileKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final Map<String, dynamic> decoded =
          jsonDecode(raw) as Map<String, dynamic>;
      return ProfileModel.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearCachedProfile() async {
    await _storageService.remove(_cachedProfileKey);
  }
}
