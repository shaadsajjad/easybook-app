import 'package:easybook_app/core/constants/app_constants.dart';
import 'package:intl/intl.dart';

/// Prices arrive as strings with two decimals in BDT, for example "500.00".
abstract final class PriceFormatter {
  /// "500.00" -> 500.0. Throws a [FormatException] for invalid input.
  static double parse(String value) => double.parse(value);

  /// 500.0 -> "৳500", 1250.5 -> "৳1,250.50". Digits follow the locale,
  /// so Bengali shows "৳৫০০".
  static String format(double amount, {String locale = 'en'}) {
    final isWhole = amount == amount.roundToDouble();
    final pattern = isWhole ? '#,##0' : '#,##0.00';
    final number = NumberFormat(pattern, locale).format(amount);
    return '${AppConstants.currencySymbol}$number';
  }
}
