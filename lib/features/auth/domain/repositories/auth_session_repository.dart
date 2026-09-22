/// Read-only view of the local session plus a local sign-out, for features
/// that must react to "is someone signed in" without reaching into auth's
/// data layer.
abstract class AuthSessionRepository {
  /// Whether both an access and a refresh token are stored.
  Future<bool> hasStoredTokens();

  /// Whether the persisted session marker says "authenticated" (as opposed to
  /// guest or signed out). The auth interceptor clears it when a refresh
  /// fails, so it is the source of truth after a 401.
  Future<bool> isAuthenticatedSession();

  /// Clears tokens, the cached user and profile, and the crash-report user
  /// context, without calling the backend. Used when the session is
  /// unrecoverable.
  Future<void> signOutLocally();
}
