/// Reusable backend endpoint constants.
///
/// All new endpoints should be defined here and referenced through this class
/// so paths are never hardcoded inside repositories, services, or screens.
abstract class ApiEndpoints {
  ApiEndpoints._();

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String registerVerify = '/auth/register/verify';
  static const String sendOtp = '/otp/send';
  static const String verifyOtp = '/otp/verify';
  static const String forgotPassword = '/auth/forgot-password';
  static const String forgotPasswordVerify = '/auth/forgot-password/verify';
  static const String changePassword = '/auth/reset-password';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String categories = '/categories';
  static const String profileMe = '/profile/me';
  static const String profileLocation = '/profile/locations';
  static const String libraries = '/libraries';
  static const String libraryRegistration = '/libraries/register';
  static const String recommendedBooks = '/books/recommended';
  static const String mostPopularBooks = '/books/most-popular';
  static const String homeCatalog = '/books/home-catalog';
  static const String cart = '/cart/me';
  static const String orders = '/orders';
  static const String cartItems = '/cart/items';
  static const String favoriteBooks = '/favorite-books';
  static const String aiSummarize = '/ai/summarize';
  static const String userPhysicalListings = '/listings/me/physical';

  static String cartItem(String listingId) => '/cart/items/$listingId';

  static String profileLocationById(String locationId) =>
      '$profileLocation/$locationId';

  static String favoriteBook(String bookId) => '/favorite-books/$bookId';

  static String libraryBooks(String libraryId) => '/libraries/$libraryId/books';

  static String listingDetails(String listingId) =>
      '/listings/$listingId/details';
}
