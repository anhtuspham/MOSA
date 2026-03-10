import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mosa/models/debt.dart';
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
  
  // Lấy các giao dịch trả nợ tương ứng
  final List<TransactionModel> transactions = [];
  for (final debt in debts) {
    if (debt.id != null) {
      final txs = await dbService.getTransactionsByDebtId(debt.id!);
      transactions.addAll(txs);
    }
  }
  
  // Gộp Debt (lúc khởi tạo nợ) và TransactionModel (lúc thanh toán) vào một timeline
  final timeline = <dynamic>[...debts, ...transactions];
  
  // Sắp xếp theo ngày (mới nhất trước)
  timeline.sort((a, b) {
    DateTime dateA = a is TransactionModel ? a.date : (a as Debt).createdDate;
    DateTime dateB = b is TransactionModel ? b.date : (b as Debt).createdDate;
    return dateB.compareTo(dateA);
  });
  
  return timeline;
});
