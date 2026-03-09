import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class NumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    // Remove any non-digit characters to get pure numeric string
    String numericString = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (numericString.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final int value = int.parse(numericString);
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0);
    String newText = formatter.format(value).trim();

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class ThousandSeparatorFormatter extends TextInputFormatter {
  final String separator;

  ThousandSeparatorFormatter({this.separator = '.'});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String decimalDigits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (decimalDigits.isEmpty) return newValue;

    String newText = '';
    int count = 0;

    for (int i = decimalDigits.length - 1; i >= 0; i--) {
      if (count == 3) {
        newText = separator + newText;
        count = 0;
      }
      newText = decimalDigits[i] + newText;
      count++;
    }

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
