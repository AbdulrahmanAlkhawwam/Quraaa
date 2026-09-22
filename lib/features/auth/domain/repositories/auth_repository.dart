import '../../../../core/use_cases/use_case.dart';
import '../entities/user.dart';

/// Account operations against the backend.
///
/// Every method that signs the user in ([login], [verifyOtp]) also persists the
/// session before returning, so a `Right` means the user is fully signed in.
abstract class AuthRepository {
  FutureEither<User> login({
    required String phoneNumber,
    required String password,
  });

  /// Creates the account. The backend then requires OTP verification, which
  /// surfaces as an `OtpVerificationRequiredFailure` on the left.
  FutureEither<User> register({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? password,
    int? gender,
    String? dateOfBirth,
    List<String>? categoryIds,
  });

  /// Exchanges the stored refresh token for a new session and persists it.
  /// Returns the new access token.
  FutureEither<String> refreshSession();

  FutureEither<bool> logout();

  FutureEither<User> verifyOtp({
    required String phoneNumber,
    required String code,
  });

  FutureEither<bool> sendOtp({required String phoneNumber});

  FutureEither<bool> forgotPassword({required String phoneNumber});

  FutureEither<bool> resetPassword({
    required String phoneNumber,
    required String code,
    required String newPassword,
  });

  FutureEither<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  });
}
