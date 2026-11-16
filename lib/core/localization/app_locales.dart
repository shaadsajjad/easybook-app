import 'dart:ui';

/// Supported languages. English is the default and the fallback.
abstract final class AppLocales {
  static const Locale english = Locale('en');
  static const Locale bengali = Locale('bn');

  static const List<Locale> supported = [english, bengali];
  static const Locale fallback = english;

  /// Folder with en.json and bn.json.
  static const String path = 'assets/translations';
}
