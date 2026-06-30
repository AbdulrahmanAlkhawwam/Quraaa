abstract class AuthRemoteDataSource {
  Future<Map<String, Object?>> login({
    required String username,
    required String password,
  });

  Future<Map<String, Object?>> register({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String password,
    required int gender,
    required String dateOfBirth,
    required List<String> interests,
  });
}
