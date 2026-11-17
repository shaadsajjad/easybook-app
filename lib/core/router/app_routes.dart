/// Every route path and name. Widgets navigate with these constants, never
/// with string literals.
abstract final class AppRoutes {
  static const String idParam = 'id';

  // Session.
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';

  // Bottom navigation tabs.
  static const String home = '/home';
  static const String bookings = '/bookings';
  static const String assistant = '/assistant';
  static const String profile = '/profile';

  // Services and booking.
  static const String serviceDetail = '/services/:$idParam';
  static const String bookService = '/services/:$idParam/book';
  static const String bookingConfirmation = '/booking-confirmation';
  static String serviceDetailPath(String id) => '/services/$id';
  static String bookServicePath(String id) => '/services/$id/book';

  // My bookings (child of the bookings tab).
  static const String bookingDetail = ':$idParam';
  static String bookingDetailPath(String id) => '$bookings/$id';

  // Profile (children of the profile tab).
  static const String editProfile = 'edit';
  static const String changePassword = 'change-password';
  static const String editProfilePath = '$profile/$editProfile';
  static const String changePasswordPath = '$profile/$changePassword';
}

/// Route names, used for `context.goNamed` and in tests.
abstract final class AppRouteNames {
  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  static const String home = 'home';
  static const String bookings = 'bookings';
  static const String assistant = 'assistant';
  static const String profile = 'profile';
  static const String serviceDetail = 'serviceDetail';
  static const String bookService = 'bookService';
  static const String bookingConfirmation = 'bookingConfirmation';
  static const String bookingDetail = 'bookingDetail';
  static const String editProfile = 'editProfile';
  static const String changePassword = 'changePassword';
}

/// Positions of the bottom-navigation tabs (same order as the shell
/// branches in app_router.dart).
abstract final class AppTabs {
  static const int home = 0;
  static const int bookings = 1;
  static const int assistant = 2;
  static const int profile = 3;
}
