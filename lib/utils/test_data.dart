// import 'package:mosa/models/transaction.dart';
// import 'package:mosa/models/enums.dart';
// import 'package:uuid/uuid.dart';
//
// class TestData {
//   static List<TransactionModel> getDummyTransactions() {
//     final now = DateTime.now();
//     final uuid = Uuid();
//
//     return [
//       // ----- Expenses -----
//       TransactionModel(
//         id: 1,
//         title: 'Ăn trưa',
//         amount: 50000,
//         category: 'Ăn uống',
//         date: now,
//         type: TransactionType.outcome,
//         note: 'Cơm văn phòng',
//         createAt: now,
//         updateAt: now,
//         isSynced: false,
//         syncId: uuid.v4(),
//       ),
//       TransactionModel(
//         id: 2,
//         title: 'Grab về nhà',
//         amount: 35000,
//         category: 'Di chuyển',
//         date: now.subtract(const Duration(days: 1)),
//         type: TransactionType.outcome,
//         note: 'Từ công ty về nhà',
//         createAt: now.subtract(const Duration(days: 1)),
//         updateAt: now.subtract(const Duration(days: 1)),
//         isSynced: false,
//         syncId: uuid.v4(),
//       ),
//       TransactionModel(
//         id: 3,
//         title: 'Xem phim',
//         amount: 120000,
//         category: 'Giải trí',
//         date: now.subtract(const Duration(days: 2)),
//         type: TransactionType.outcome,
//         note: 'Deadpool & Wolverine',
//         createAt: now.subtract(const Duration(days: 2)),
//         updateAt: now.subtract(const Duration(days: 2)),
//         isSynced: false,
//         syncId: uuid.v4(),
//       ),
//       TransactionModel(
//         id: 4,
//         title: 'Mua sách',
//         amount: 250000,
//         category: 'Học tập',
//         date: now.subtract(const Duration(days: 3)),
//         type: TransactionType.outcome,
//         note: 'Sách Flutter nâng cao',
//         createAt: now.subtract(const Duration(days: 3)),
//         updateAt: now.subtract(const Duration(days: 3)),
//         isSynced: true,
//         syncId: uuid.v4(),
//       ),
//
//       // ----- Incomes -----
//       TransactionModel(
//         id: 5,
//         title: 'Lương tháng 10',
//         amount: 15000000,
//         category: 'Lương',
//         date: DateTime(now.year, now.month, 1),
//         type: TransactionType.income,
//         note: 'Lương công ty ABC',
//         createAt: DateTime(now.year, now.month, 1),
//         updateAt: DateTime(now.year, now.month, 1),
//         isSynced: true,
//         syncId: uuid.v4(),
//       ),
//       TransactionModel(
//         id: 6,
//         title: 'Thưởng dự án',
//         amount: 3000000,
//         category: 'Thưởng',
//         date: now.subtract(const Duration(days: 5)),
//         type: TransactionType.income,
//         note: 'Hoàn thành đúng tiến độ',
//         createAt: now.subtract(const Duration(days: 5)),
//         updateAt: now.subtract(const Duration(days: 5)),
//         isSynced: false,
//         syncId: uuid.v4(),
//       ),
//
//       // ----- Others (lend & borrowing) -----
//       TransactionModel(
//         id: 7,
//         title: 'Cho mượn Minh',
//         amount: 200000,
//         category: 'Cho vay',
//         date: now.subtract(const Duration(days: 2)),
//         type: TransactionType.lend,
//         note: 'Minh hẹn trả cuối tuần',
//         createAt: now.subtract(const Duration(days: 2)),
//         updateAt: now.subtract(const Duration(days: 2)),
//         isSynced: false,
//         syncId: uuid.v4(),
//       ),
//       TransactionModel(
//         id: 8,
//         title: 'Mượn Hùng',
//         amount: 100000,
//         category: 'Đi vay',
//         date: now.subtract(const Duration(days: 4)),
//         type: TransactionType.borrowing,
//         note: 'Mượn Hùng tiền cà phê',
//         createAt: now.subtract(const Duration(days: 4)),
//         updateAt: now.subtract(const Duration(days: 4)),
//         isSynced: false,
//         syncId: uuid.v4(),
//       ),
//     ];
//   }
// }
