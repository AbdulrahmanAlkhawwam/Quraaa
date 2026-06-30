import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login({
    required String phoneNumber,
    required String password,
  });

  Future<User> register({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? password,
    int? gender,
    String? dateOfBirth,
    List<String>? categoryIds,
  });

  Future<User> refreshToken({
    required String refreshToken,
  });
}
