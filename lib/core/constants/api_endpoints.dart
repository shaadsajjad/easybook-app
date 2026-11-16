/// Relative API paths. The base URL (with /api/v1) comes from AppConfig.
abstract final class ApiEndpoints {
  static const String health = '/health';

  static const String register = '/auth/register';
  static const String login = '/auth/login';

  static const String me = '/users/me';
  static const String changePassword = '/users/me/password';

  static const String services = '/services';
  static const String categories = '/services/categories';
  static String serviceById(String id) => '/services/$id';
  static String availability(String id) => '/services/$id/availability';

  static const String appointments = '/appointments';
  static String appointmentById(String id) => '/appointments/$id';
  static String cancelAppointment(String id) => '/appointments/$id/cancel';

  static const String aiChat = '/ai/chat';

  /// Public routes where a 401 means "wrong credentials", not
  /// "session expired". A 401 here must never log the user out.
  static const Set<String> credentialRoutes = {login, register};
}
