import '../../../../core/architecture/result.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Result<User>> login({
    required String phoneNumber,
    required String password,
  });

  Future<Result<User>> register({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? password,
    int? gender,
    String? dateOfBirth,
    List<String>? categoryIds,
  });

  Future<Result<User>> refreshToken({required String refreshToken});

  Future<Result<User>> verifyOtp({
    required String phoneNumber,
    required String code,
  });

  Future<Result<bool>> forgotPassword({required String phoneNumber});

  Future<Result<bool>> resetPassword({
    required String phoneNumber,
    required String code,
    required String newPassword,
  });
}
