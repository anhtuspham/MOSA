import 'dart:developer';

import 'package:mosa/models/enums.dart';
import 'package:mosa/models/transaction.dart';
import 'package:mosa/models/transaction_type_config.dart';

class TransactionAggregator {
  static ({double income, double expense}) calculatorTotals(
    List<TransactionModel> transactions,
  ) {
    double income = 0;
    double expense = 0;

    for (var transaction in transactions) {
      final balanceEffect = TransactionTypeManager.getBalanceEffect(
        transaction.type,
      );
      log('balanceEffect: ${balanceEffect.toString()}');
      switch (balanceEffect) {
        case BalanceEffect.plus:
          income += transaction.amount;
          break;
        case BalanceEffect.minus:
          expense += transaction.amount;
          break;
        case BalanceEffect.neutral:
          break;
      }
    }

    return (income: income, expense: expense);
  }

  static double sumByType(
    List<TransactionModel> transactions,
    TransactionType type,
  ) {
    return transactions
        .where((element) => element.type == type)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  static double sumByBalanceEffect(
    List<TransactionModel> transactions,
    BalanceEffect effect,
  ) {
    return transactions
        .where((t) => TransactionTypeManager.getBalanceEffect(t.type) == effect)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  static double sumByCategory(
    List<TransactionModel> transactions,
    TransactionCategory category,
  ) {
    return transactions
        .where((t) => TransactionTypeManager.getCategory(t.type) == category)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  static double calculateBalanceImpact(List<TransactionModel> transactions) {
    return transactions.fold(0.0, (balance, transaction) {
      return balance +
          TransactionTypeManager.calculateBalanceImpact(
            transaction.type,
            transaction.amount,
          );
    });
  }

  static List<TransactionModel> filterByCategory(
    List<TransactionModel> transactions,
    TransactionCategory category,
  ) {
    return transactions
        .where((t) => TransactionTypeManager.getCategory(t.type) == category)
        .toList();
  }

  static List<TransactionModel> filterByBalanceEffect(
    List<TransactionModel> transactions,
    BalanceEffect effect,
  ) {
    return transactions
        .where((t) => TransactionTypeManager.getBalanceEffect(t.type) == effect)
        .toList();
  }
}
