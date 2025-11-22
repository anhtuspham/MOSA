import 'package:flutter/cupertino.dart';


TextPainter getTextPainter(String text, {BuildContext? context}) {
  return TextPainter(text: TextSpan(text: text, style: TextStyle(fontSize: 14)), textDirection: TextDirection.ltr)..layout();
}