abstract class AuthRemoteDataSource {
  Future<Map<String, Object?>> login({
    required String username,
    required String password,
  });
}
