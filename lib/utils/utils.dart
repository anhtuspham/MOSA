import 'package:flutter/cupertino.dart';

String formatCurrency(double amount) {
  return '${amount.toStringAsFixed(0)}đ';
}

TextPainter getTextPainter(String text, {BuildContext? context}) {
  return TextPainter(text: TextSpan(text: text, style: TextStyle(fontSize: 14)), textDirection: TextDirection.ltr)..layout();
}
