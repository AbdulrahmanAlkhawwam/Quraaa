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
  static String validateIsbn(String isbn) =>
      '/books/validate-isbn/${Uri.encodeComponent(isbn)}';
  static const String cart = '/cart/me';
  static const String orders = '/orders';
  static const String ordersCheckoutContext = '/orders/checkout-context';
  static const String ordersMine = '/orders/me';
  static const String cartItems = '/cart/items';
  static const String favoriteBooks = '/favorite-books';
  static const String aiSummarize = '/ai/summarize';
  static const String userPhysicalListings = '/listings/me/physical';
  static const String myOrders = '/orders/me';
  static const String buyHistory = '/purchases/me/buy-history';
  static const String sellHistory = '/purchases/me/sell-history';
  static const String myListings = '/listings/me';
  static const String sellerOrders = '/seller/orders';
  static const String aiTranslate = '/ai/translate';
  static const String aiExplain = '/ai/explain';
  static const String bookReportReasons = '/book-reports/reasons';
  static const String notificationDevices = '/notifications/devices';
  static const String libraryRegistrationContext =
      '/libraries/register/context';
  static const String libraryRegistrationSubmit = '/libraries/register/submit';
  static const String libraryProfile = '/libraries/my-profile';

  static String cartItem(String listingId) => '/cart/items/$listingId';

  static String profileLocationById(String locationId) =>
      '$profileLocation/$locationId';

  static String favoriteBook(String bookId) => '/favorite-books/$bookId';

  static String libraryBooks(String libraryId) => '/libraries/$libraryId/books';

  static String listingDetails(String listingId) =>
      '/listings/$listingId/details';

  static String order(String orderId) => '/orders/$orderId';
  static String orderCancel(String orderId) => '/orders/$orderId/cancel';
  static String orderShippingLocation(String orderId) =>
      '/orders/$orderId/shipping-location';
  static String orderCheckoutSession(String orderId) =>
      '/orders/$orderId/checkout-session';
  static String orderItemDownload(String orderId, String orderItemId) =>
      '/orders/$orderId/items/$orderItemId/download';
  static String purchaseStream(String purchaseId) =>
      '/purchases/$purchaseId/stream';
  static String author(String authorId) => '/authors/$authorId';
  static String authorBooks(String authorId) => '/authors/$authorId/books';
  static String bookReviews(String bookId) => '/books/$bookId/reviews';
  static String bookReports(String bookId) => '/books/$bookId/reports';
  static String profileLocationDefault(String locationId) =>
      '/profile/locations/$locationId/default';
  static String sellerOrderProcessing(String orderId, String orderItemId) =>
      '/seller/orders/$orderId/items/$orderItemId/processing';
  static String sellerOrderFulfilled(String orderId, String orderItemId) =>
      '/seller/orders/$orderId/items/$orderItemId/fulfilled';
}
