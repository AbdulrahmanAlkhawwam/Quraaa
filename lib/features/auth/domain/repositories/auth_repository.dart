import '../entities/auth_user.dart';
import '../entities/auth_tokens.dart';

abstract class AuthRepository {
  Future<AuthUser> login({
    required String username,
    required String password,
  });

  Future<AuthTokens> register({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String password,
    required int gender,
    required String dateOfBirth,
    required List<String> interests,
  });
}
