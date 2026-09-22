import '../../../../core/error_monitoring/user_context_provider.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';

/// Refreshes and caches the authenticated profile once after a successful login.
class ProfileBootstrapService {
  const ProfileBootstrapService(this._repository, this._userContextProvider);

  final ProfileRepository _repository;
  final UserContextProvider _userContextProvider;

  /// Best effort: a failed fetch leaves the crash-report context as it was,
  /// and must never turn a valid login into an error.
  Future<void> refreshAfterLogin() async {
    final Profile? profile = (await _repository.getMyProfile()).toNullable();
    if (profile == null) return;
    final snapshot = _userContextProvider.snapshot;
    await _userContextProvider.setUser(
      id: profile.userId ?? snapshot.userId ?? 'authenticated',
      name: profile.fullName,
      phone: profile.phoneNumber ?? snapshot.userPhone,
      subscriptionStatus: 'active',
    );
  }
}
