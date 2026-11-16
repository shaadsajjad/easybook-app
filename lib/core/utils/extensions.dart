import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/error/failures.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;

  /// Status bar icons that stay readable on the page background (dark icons
  /// in light mode). Pages with a gradient header use the light style.
  SystemUiOverlayStyle get pageOverlayStyle =>
      Theme.of(this).brightness == Brightness.dark
      ? SystemUiOverlayStyle.light
      : SystemUiOverlayStyle.dark;

  /// The active language code ("en" or "bn"), for intl formatting.
  /// Read from Flutter's Localizations (kept in sync by easy_localization),
  /// so widgets also work in tests without EasyLocalization.
  String get localeName => Localizations.localeOf(this).languageCode;

  void showSnackBar(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

extension FailureX on Failure {
  /// The API's message when there is one (it is already friendly),
  /// otherwise a localized fallback for this kind of failure.
  String get displayMessage {
    if (message.isNotEmpty) return message;
    return switch (this) {
      NetworkFailure() => LocaleKeys.errors_network.tr(),
      UnauthorizedFailure() => LocaleKeys.errors_session_expired.tr(),
      NotFoundFailure() => LocaleKeys.errors_not_found.tr(),
      RateLimitFailure() => LocaleKeys.errors_rate_limited.tr(),
      ServiceUnavailableFailure() => LocaleKeys.errors_unavailable.tr(),
      ValidationFailure() ||
      ConflictFailure() ||
      ServerFailure() => LocaleKeys.errors_generic.tr(),
    };
  }
}
