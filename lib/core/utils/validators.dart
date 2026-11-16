import 'package:easy_localization/easy_localization.dart';
import 'package:easybook_app/core/constants/app_constants.dart';
import 'package:easybook_app/core/localization/locale_keys.g.dart';

/// Form validators with the same rules as the API, so users get instant
/// feedback. Each returns a translated message, or null when valid.
abstract final class Validators {
  static final RegExp _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final RegExp _letter = RegExp('[A-Za-z]');
  static final RegExp _digit = RegExp('[0-9]');
  static final RegExp _phoneChars = RegExp(r'^\+?[0-9 \-]+$');

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return LocaleKeys.validation_email_required.tr();
    if (email.length > AppConstants.emailMaxLength || !_email.hasMatch(email)) {
      return LocaleKeys.validation_email_invalid.tr();
    }
    return null;
  }

  static String? name(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return LocaleKeys.validation_name_required.tr();
    if (name.length < AppConstants.nameMinLength) {
      return LocaleKeys.validation_name_min.tr(
        namedArgs: {'min': '${AppConstants.nameMinLength}'},
      );
    }
    if (name.length > AppConstants.nameMaxLength) {
      return LocaleKeys.validation_name_max.tr(
        namedArgs: {'max': '${AppConstants.nameMaxLength}'},
      );
    }
    return null;
  }

  /// Full password rules: 8-72 characters, a letter and a number.
  static String? password(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return LocaleKeys.validation_password_required.tr();
    if (password.length < AppConstants.passwordMinLength) {
      return LocaleKeys.validation_password_min.tr(
        namedArgs: {'min': '${AppConstants.passwordMinLength}'},
      );
    }
    if (password.length > AppConstants.passwordMaxLength) {
      return LocaleKeys.validation_password_max.tr(
        namedArgs: {'max': '${AppConstants.passwordMaxLength}'},
      );
    }
    if (!_letter.hasMatch(password)) {
      return LocaleKeys.validation_password_letter.tr();
    }
    if (!_digit.hasMatch(password)) {
      return LocaleKeys.validation_password_number.tr();
    }
    return null;
  }

  /// Login only checks that a password was typed; the server decides if it
  /// is correct (old accounts may predate a rule change).
  static String? requiredPassword(String? value) {
    if (value == null || value.isEmpty) {
      return LocaleKeys.validation_password_required.tr();
    }
    return null;
  }

  /// A new password must follow the rules and differ from the current one.
  static String? newPassword(String? value, {required String current}) {
    final error = password(value);
    if (error != null) return error;
    if (value == current) return LocaleKeys.validation_password_same.tr();
    return null;
  }

  static String? confirmPassword(String? value, {required String original}) {
    if (value != original) return LocaleKeys.validation_password_mismatch.tr();
    return null;
  }

  /// Phone is optional. When given: 7-20 digits, may start with +, spaces
  /// and dashes allowed.
  static String? phone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return null;
    final digits = phone.replaceAll(RegExp('[^0-9]'), '').length;
    if (!_phoneChars.hasMatch(phone) || digits < 7 || digits > 20) {
      return LocaleKeys.validation_phone_invalid.tr();
    }
    return null;
  }
}
