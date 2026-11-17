import 'dart:convert';
import 'dart:io';
import 'dart:ui';

// easy_localization has no public way to load translations without its
// widget, so tests use its internal loader directly.
// ignore: documented above.
import 'package:easy_localization/src/localization.dart';
// ignore: documented above.
import 'package:easy_localization/src/translations.dart';

/// Makes `tr()` return the real text of [languageCode] ("en" or "bn").
void loadTranslations(String languageCode) {
  final file = File('assets/translations/$languageCode.json');
  final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  Localization.load(Locale(languageCode), translations: Translations(json));
}

/// Back to the test default: `tr()` returns the key itself.
void unloadTranslations() => Localization.load(const Locale('en'));
