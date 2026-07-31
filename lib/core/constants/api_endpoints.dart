/// Reusable backend endpoint constants.
///
/// All new endpoints should be defined here and referenced through this class
/// so paths are never hardcoded inside repositories, services, or screens.
abstract class ApiEndpoints {
  ApiEndpoints._();

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyOtp = '/otp/verify';
  static const String forgotPassword = '/auth/forgot-password';
  static const String forgotPasswordVerify = '/auth/forgot-password/verify';
  static const String refreshToken = '/auth/refresh';
  static const String categories = '/categories';
  static const String profileMe = '/profile/me';
  static const String profileLocation = '/profile/location';
  static const String libraries = '/libraries';
  static const String recommendedBooks = '/books/recommended';
  static const String mostPopularBooks = '/books/most-popular';

  static String libraryBooks(String libraryId) => '/libraries/$libraryId/books';
}
