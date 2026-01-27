import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:mosa/models/enums.dart';
import 'package:mosa/models/transaction_type_config.dart';
import 'dart:math' as math;

TextPainter getTextPainter(String text, {BuildContext? context}) {
  return TextPainter(text: TextSpan(text: text, style: TextStyle(fontSize: 14)), textDirection: TextDirection.ltr)..layout();
}

String generateSyncId() {
  return DateTime.now().millisecondsSinceEpoch.toString() + math.Random().nextInt(1000).toString();
}

int generateId() {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final random = math.Random().nextInt(99999);

  final last5 = timestamp % 100000;

  return last5 * 100000 + random;
}

TransactionType getTransactionTypeFromString(String type) {
  switch (type.toLowerCase()) {
    case 'income':
      return TransactionType.income;
    case 'expense':
      return TransactionType.expense;
    case 'lend':
      return TransactionType.lend;
    case 'borrowing':
      log('type borrowing: $type');
      return TransactionType.borrowing;
    case 'transfer':
    case 'transferOut':
    case 'transferIn':
      return TransactionType.transfer;
    default:
      return TransactionType.unknown;
  }
}

/// Maps category ID or name to the correct TransactionType
/// Handles special cases for lending/borrowing categories
TransactionType getTransactionTypeFromCategory(String categoryId, String categoryName) {
  // Check by category ID first (more reliable)
  switch (categoryId) {
    case 'lend_borrow': // "Cho vay" - lending money out
      return TransactionType.lend;
    case 'lend_receive': // "Mượn" - borrowing money in
      return TransactionType.borrowing;
    case 'lend_payback': // "Trả nợ" - paying back a debt
      return TransactionType.expense;
    case 'lend_collect': // "Thu nợ" - collecting debt
      return TransactionType.income;
    default:
      // Fallback: check by name if ID doesn't match
      switch (categoryName.toLowerCase()) {
        case 'cho vay':
          return TransactionType.lend;
        case 'mượn':
          return TransactionType.borrowing;
        case 'trả nợ':
          return TransactionType.repayment;
        case 'thu nợ':
          return TransactionType.debtCollection;
        default:
          // If not a special category, return unknown
          return TransactionType.unknown;
      }
  }
}

String? getCategoryNameForTransactionType(TransactionType type) {
  switch (type) {
    case TransactionType.lend:
      return 'Cho vay';
    case TransactionType.borrowing:
      return 'Mượn';
    case TransactionType.repayment:
    case TransactionType.debtCollection:
    case TransactionType.transfer:
    case TransactionType.transferIn:
    case TransactionType.transferOut:
    case TransactionType.adjustBalance:
      return null;
    case TransactionType.expense:
    case TransactionType.income:
    case TransactionType.unknown:
      return null;
  }
}

Color getTransactionTypeColor({TransactionType type = TransactionType.expense}) {
  return TransactionTypeManager.getColor(type);
}
