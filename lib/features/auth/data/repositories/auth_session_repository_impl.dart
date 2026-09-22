import '../../domain/repositories/auth_session_repository.dart';
import '../data_sources/auth_local_data_source.dart';
import '../services/auth_session_service.dart';

class AuthSessionRepositoryImpl implements AuthSessionRepository {
  const AuthSessionRepositoryImpl(this._local, this._sessionService);

  final AuthLocalDataSource _local;
  final AuthSessionService _sessionService;

  @override
  Future<bool> hasStoredTokens() async {
    final String? access = await _local.getAccessToken();
    final String? refresh = await _local.getRefreshToken();
    return (access?.isNotEmpty ?? false) && (refresh?.isNotEmpty ?? false);
  }

  @override
  Future<bool> isAuthenticatedSession() => _local.isAuthenticatedSession();

  @override
  Future<void> signOutLocally() => _sessionService.expireAuthenticatedSession();
}
