import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat('#,###', 'en');

  static String format(num amount) {
    return _formatter.format(amount);
  }

  static String formatWithCurrency(num amount) {
    return "${_formatter.format(amount)} جنيه";
  }
}