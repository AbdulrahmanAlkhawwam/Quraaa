import '../../../../core/error_monitoring/user_context_provider.dart';
import '../../domain/repositories/profile_repository.dart';

/// Refreshes and caches the authenticated profile once after a successful login.
class ProfileBootstrapService {
  const ProfileBootstrapService(this._repository, this._userContextProvider);

  final ProfileRepository _repository;
  final UserContextProvider _userContextProvider;

  Future<void> refreshAfterLogin() async {
    final profile = await _repository.getMyProfile();
    final snapshot = _userContextProvider.snapshot;
    await _userContextProvider.setUser(
      id: profile.userId ?? snapshot.userId ?? 'authenticated',
      name: profile.fullName,
      phone: profile.phoneNumber ?? snapshot.userPhone,
      subscriptionStatus: 'active',
    );
  }
}
