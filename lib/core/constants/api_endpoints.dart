/// Reusable backend endpoint constants.
///
/// All new endpoints should be defined here and referenced through this class
/// so paths are never hardcoded inside repositories, services, or screens.
abstract class ApiEndpoints {
  ApiEndpoints._();

  static const String login = '/Auth/login';
  static const String register = '/Auth/register';
  static const String verifyOtp = '/Otp/verify';
  static const String forgotPassword = '/Auth/forgot-password';
  static const String resetPassword = '/Auth/reset-password';
  static const String refreshToken = '/api/Auth/refresh';
  static const String categories = '/Categories';
  static const String profileMe = '/Profile/me';
  static const String libraries = '/Libraries';

  static String libraryBooks(String libraryId) => '/Libraries/$libraryId/books';
}
