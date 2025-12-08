import 'package:flutter/services.dart';

class ThousandSeperatorFormatter extends TextInputFormatter {
  final String seperator;

  ThousandSeperatorFormatter({this.seperator = ','});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String numbericOnly = newValue.text.replaceAll(',', '');

    if (!RegExp(r'^\d+$').hasMatch(numbericOnly)) {
      return oldValue;
    }

    String formatted = '';
    for (int i = 0; i < numbericOnly.length; i++) {
      if (i > 0 && (numbericOnly.length - i) % 3 == 0) {
        formatted += seperator;
      }
      formatted += numbericOnly[i];
    }

    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}