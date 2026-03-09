import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String formatVND(double amount) {
    if (amount == 0) return '0 đ';
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return formatter.format(amount);
  }

  static String formatNumber(double amount) {
    if (amount == 0) return '0';
    final formatter = NumberFormat('#,###', 'vi_VN');
    return formatter.format(amount);
  }
}
