import 'package:flutter/services.dart';

class ThousandSeparatorFormatter extends TextInputFormatter {
  final String separator;

  ThousandSeparatorFormatter({this.separator = ','});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String numericOnly = newValue.text.replaceAll(separator, '');

    if (!RegExp(r'^\d+$').hasMatch(numericOnly)) {
      return oldValue;
    }

    String formatted = '';
    for (int i = 0; i < numericOnly.length; i++) {
      if (i > 0 && (numericOnly.length - i) % 3 == 0) {
        formatted += separator;
      }
      formatted += numericOnly[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
