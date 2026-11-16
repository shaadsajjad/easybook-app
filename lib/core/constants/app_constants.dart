/// App-wide limits and timings. Values mirror the rules in docs/API.md.
abstract final class AppConstants {
  // Network. The free Render server sleeps when idle, so the first request
  // can take 30-50 seconds.
  static const Duration connectTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration chatReceiveTimeout = Duration(seconds: 30);
  static const Duration wakeUpHintDelay = Duration(seconds: 4);

  // Services list.
  static const Duration searchDebounce = Duration(milliseconds: 300);
  static const int servicesPageSize = 20;

  // Booking.
  static const int bookingDaysAhead = 14;
  static const int notesMaxLength = 500;
  static const String businessTimeZone = 'Asia/Dhaka';

  // Account rules (same as the API).
  static const int nameMinLength = 2;
  static const int nameMaxLength = 100;
  static const int passwordMinLength = 8;
  static const int passwordMaxLength = 72;
  static const int emailMaxLength = 254;

  // AI assistant.
  static const int chatMessageMaxLength = 500;
  static const int chatHistoryLimit = 10;

  // The public demo account seeded on the backend (see docs/API.md,
  // "Demo credentials"). Shown as a one-tap shortcut on the login screen.
  static const String demoEmail = 'demo@example.com';
  static const String demoPassword = 'Demo1234';

  // Currency shown next to prices (Bangladeshi Taka).
  static const String currencySymbol = '৳';
}
