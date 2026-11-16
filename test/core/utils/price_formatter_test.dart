import 'package:easybook_app/core/utils/price_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PriceFormatter.parse', () {
    test('parses the API price string', () {
      expect(PriceFormatter.parse('500.00'), 500);
      expect(PriceFormatter.parse('1250.50'), 1250.5);
    });

    test('throws on invalid input', () {
      expect(() => PriceFormatter.parse('abc'), throwsFormatException);
    });
  });

  group('PriceFormatter.format', () {
    test('hides decimals for whole amounts', () {
      expect(PriceFormatter.format(500), '৳500');
      expect(PriceFormatter.format(3000), '৳3,000');
    });

    test('shows two decimals otherwise', () {
      expect(PriceFormatter.format(1250.5), '৳1,250.50');
    });

    test('uses Bengali digits for the bn locale', () {
      expect(PriceFormatter.format(500, locale: 'bn'), '৳৫০০');
    });
  });
}
