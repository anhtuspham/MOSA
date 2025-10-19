import '../models/transaction.dart';

class TestData {
  static List<TransactionModel> getDummyTransactions() {
    final now = DateTime.now();

    return [
      // Expenses
      TransactionModel(
        title: 'Ăn trưa',
        amount: 50000,
        category: 'Ăn uống',
        date: now,
        type: 'expense',
        note: 'Cơm văn phòng',
      ),
      TransactionModel(
        title: 'Grab về nhà',
        amount: 35000,
        category: 'Di chuyển',
        date: now.subtract(const Duration(days: 1)),
        type: 'expense',
      ),
      TransactionModel(
        title: 'Xem phim',
        amount: 120000,
        category: 'Giải trí',
        date: now.subtract(const Duration(days: 2)),
        type: 'expense',
        note: 'Deadpool & Wolverine',
      ),
      TransactionModel(
        title: 'Mua sách',
        amount: 250000,
        category: 'Học tập',
        date: now.subtract(const Duration(days: 3)),
        type: 'expense',
      ),

      // Income
      TransactionModel(
        title: 'Lương tháng 10',
        amount: 15000000,
        category: 'Lương',
        date: DateTime(now.year, now.month, 1),
        type: 'income',
      ),
      TransactionModel(
        title: 'Thưởng dự án',
        amount: 3000000,
        category: 'Thưởng',
        date: now.subtract(const Duration(days: 5)),
        type: 'income',
      ),
    ];
  }
}