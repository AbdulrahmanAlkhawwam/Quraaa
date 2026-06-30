class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiration,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime accessTokenExpiration;
}
