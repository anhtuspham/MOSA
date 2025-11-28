import 'package:mosa/models/enums.dart';
import 'package:mosa/models/transaction.dart';

class TransactionAggregator {
  static ({double income, double expense}) calculatorTotals(List<TransactionModel> transactions) {
    double income = 0;
    double expense = 0;

    for (var transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
    }

    return (income: income, expense: expense);
  }

  static double sumByType(List<TransactionModel> transactions, TransactionType type) {
    return transactions.where((element) => element.type == type).fold(0.0, (sum, t) => sum + t.amount);
  }
}
