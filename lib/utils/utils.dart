
import 'package:flutter/cupertino.dart';
import 'package:mosa/models/enums.dart';
import 'package:mosa/models/transaction_type_config.dart';
import 'dart:math' as math;

TextPainter getTextPainter(String text, {BuildContext? context}) {
  return TextPainter(
    text: TextSpan(text: text, style: TextStyle(fontSize: 14)),
    textDirection: TextDirection.ltr,
  )..layout();
}

String generateSyncId() {
  return DateTime.now().millisecondsSinceEpoch.toString() +
      math.Random().nextInt(1000).toString();
}

int generateId() {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final random = math.Random().nextInt(99999);

  final last5 = timestamp % 100000;

  return last5 * 100000 + random;
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
    case 'transfer':
    case 'transferOut':
    case 'transferIn':
      return TransactionType.transfer;
    default:
      return TransactionType.expense;
  }
}

Color getTransactionTypeColor({
  TransactionType type = TransactionType.expense,
}) {
  return TransactionTypeManager.getColor(type);
}
