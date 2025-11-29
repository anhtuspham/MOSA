import 'package:flutter/cupertino.dart';
import 'package:mosa/models/enums.dart';

TextPainter getTextPainter(String text, {BuildContext? context}) {
  return TextPainter(text: TextSpan(text: text, style: TextStyle(fontSize: 14)), textDirection: TextDirection.ltr)
    ..layout();
}

TransactionType getTransactionType(String type) {
  switch (type.toLowerCase()) {
    case 'income':
      return TransactionType.income;
    case 'expense':
      return TransactionType.expense;
    case 'lend':
      return TransactionType.lend;
    case 'borrowing':
      return TransactionType.borrowing;
    default:
      return TransactionType.expense;
  }
}
