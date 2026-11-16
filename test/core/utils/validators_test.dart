import 'package:easybook_app/core/localization/locale_keys.g.dart';
import 'package:easybook_app/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

// Translations are not loaded in unit tests, so tr() returns the key.
// That lets us check exactly which rule failed.
void main() {
  group('Validators.email', () {
    test('accepts a valid email, ignoring surrounding spaces', () {
      expect(Validators.email(' ayesha@example.com '), isNull);
    });

    test('requires a value', () {
      expect(Validators.email(''), LocaleKeys.validation_email_required);
      expect(Validators.email(null), LocaleKeys.validation_email_required);
    });

    test('rejects malformed emails', () {
      for (final value in ['ayesha', 'ayesha@', '@example.com', 'a b@c.d']) {
        expect(
          Validators.email(value),
          LocaleKeys.validation_email_invalid,
          reason: value,
        );
      }
    });
  });

  group('Validators.name', () {
    test('accepts 2-100 characters', () {
      expect(Validators.name('Al'), isNull);
      expect(Validators.name('A' * 100), isNull);
    });

    test('rejects empty, too short and too long names', () {
      expect(Validators.name('  '), LocaleKeys.validation_name_required);
      expect(Validators.name(' A '), LocaleKeys.validation_name_min);
      expect(Validators.name('A' * 101), LocaleKeys.validation_name_max);
    });
  });

  group('Validators.password', () {
    test('accepts 8-72 characters with a letter and a number', () {
      expect(Validators.password('Secret123'), isNull);
    });

    test('applies each rule in order', () {
      expect(Validators.password(''), LocaleKeys.validation_password_required);
      expect(Validators.password('abc1'), LocaleKeys.validation_password_min);
      expect(
        Validators.password('a1${'b' * 71}'),
        LocaleKeys.validation_password_max,
      );
      expect(
        Validators.password('12345678'),
        LocaleKeys.validation_password_letter,
      );
      expect(
        Validators.password('abcdefgh'),
        LocaleKeys.validation_password_number,
      );
    });

    test('requiredPassword only checks that something was typed', () {
      expect(Validators.requiredPassword('x'), isNull);
      expect(
        Validators.requiredPassword(''),
        LocaleKeys.validation_password_required,
      );
    });

    test('newPassword must differ from the current password', () {
      expect(Validators.newPassword('NewPass456', current: 'Old123ab'), isNull);
      expect(
        Validators.newPassword('Same1234', current: 'Same1234'),
        LocaleKeys.validation_password_same,
      );
      expect(
        Validators.newPassword('short1', current: 'Old123ab'),
        LocaleKeys.validation_password_min,
      );
    });

    test('confirmPassword must match', () {
      expect(Validators.confirmPassword('abc', original: 'abc'), isNull);
      expect(
        Validators.confirmPassword('abd', original: 'abc'),
        LocaleKeys.validation_password_mismatch,
      );
    });
  });

  group('Validators.phone', () {
    test('is optional', () {
      expect(Validators.phone(''), isNull);
      expect(Validators.phone(null), isNull);
    });

    test('accepts 7-20 digits with an optional +, spaces and dashes', () {
      expect(Validators.phone('+8801712345678'), isNull);
      expect(Validators.phone('017 1234-5678'), isNull);
      expect(Validators.phone('1234567'), isNull);
    });

    test('rejects letters, too few or too many digits', () {
      expect(Validators.phone('12345'), LocaleKeys.validation_phone_invalid);
      expect(Validators.phone('1' * 21), LocaleKeys.validation_phone_invalid);
      expect(Validators.phone('01712abc'), LocaleKeys.validation_phone_invalid);
      expect(
        Validators.phone('88+017123'),
        LocaleKeys.validation_phone_invalid,
      );
    });
  });

  group('Validators.optionalAmount', () {
    test('accepts empty and non-negative numbers', () {
      expect(Validators.optionalAmount(''), isNull);
      expect(Validators.optionalAmount('0'), isNull);
      expect(Validators.optionalAmount('1250.5'), isNull);
    });

    test('rejects text and negative numbers', () {
      expect(
        Validators.optionalAmount('abc'),
        LocaleKeys.services_price_invalid,
      );
      expect(
        Validators.optionalAmount('-5'),
        LocaleKeys.services_price_invalid,
      );
    });
  });
}
