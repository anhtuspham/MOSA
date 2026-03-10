import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mosa/models/debt.dart';
import 'package:mosa/models/enums.dart';
import 'package:mosa/models/transaction.dart';
import 'package:mosa/providers/database_service_provider.dart';

/// Lấy danh sách giao dịch liên quan đến một khoản nợ (Lịch sử thanh toán của khoản nợ cụ thể)
final debtTransactionsProvider = FutureProvider.family<List<TransactionModel>, int>((ref, debtId) async {
  final dbService = ref.read(databaseServiceProvider);
  return await dbService.getTransactionsByDebtId(debtId);
});

/// Timeline tổng hợp của một người (tất cả các khoản nợ và giao dịch của họ)
final personDebtTimelineProvider = FutureProvider.family<List<dynamic>, int>((ref, personId) async {
  final dbService = ref.read(databaseServiceProvider);
  
  // Lấy các khoản nợ (cho vay / mượn)
  final debts = await dbService.getDebtByPersonId(personId);
  
  // Lấy các giao dịch liên quan đến người này (bao gồm cả trả nợ gộp không có debtId)
  final List<TransactionModel> transactions = await dbService.getTransactionsByPersonId(personId);
  
  // Gộp Debt (lúc khởi tạo nợ) và TransactionModel (lúc thanh toán) vào một timeline
  // Lưu ý: Chúng ta lọc bỏ các Transaction có type là lend hoặc borrowing 
  // vì chúng đại diện cho việc khởi tạo khoản nợ, vốn đã được hiển thị bởi đối tượng Debt.
  final filteredTransactions = transactions.where((tx) => 
    tx.type != TransactionType.lend && tx.type != TransactionType.borrowing
  ).toList();

  final timeline = <dynamic>[...debts, ...filteredTransactions];
  
  // Sắp xếp theo ngày (mới nhất trước)
  timeline.sort((a, b) {
    DateTime dateA = a is TransactionModel ? a.date : (a as Debt).createdDate;
    DateTime dateB = b is TransactionModel ? b.date : (b as Debt).createdDate;
    return dateB.compareTo(dateA);
  });
  
  return timeline;
});
