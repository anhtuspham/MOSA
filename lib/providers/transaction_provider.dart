import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mosa/models/enums.dart';
import 'package:mosa/providers/category_provider.dart';
import 'package:mosa/providers/date_filter_provider.dart';
import 'package:mosa/providers/wallet_provider.dart';
import 'package:mosa/services/database_service.dart';
import 'package:mosa/utils/collection_utils.dart';
import 'package:mosa/utils/date_utils.dart';

import '../models/category.dart';
import '../models/transaction.dart';
import 'database_service_provider.dart';

/// Cung cấp quyền truy cập dịch vụ cơ sở dữ liệu cho các hoạt động giao dịch

class TransactionNotifier extends AsyncNotifier<List<TransactionModel>> {
  @override
  Future<List<TransactionModel>> build() async {
    return await _databaseService.getAllTransactions();
  }

  DatabaseService get _databaseService => ref.read(databaseServiceProvider);

  WalletsNotifier get _walletController => ref.read(walletProvider.notifier);

  Future<void> addTransaction(TransactionModel transaction) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final id = await _databaseService.insertTransaction(transaction);
      await _walletController.refreshWallet();
      final newTransaction = transaction.copyWith(id: id);
      return [newTransaction, ...state.requireValue];
    });
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _databaseService.updateTransaction(transaction);
      await _walletController.refreshWallet();
      final index = state.requireValue.indexWhere((element) => element == transaction);
      if (index != -1) {
        return [...state.requireValue.sublist(0, index), transaction, ...state.requireValue.sublist(index + 1)];
      }
      return state.requireValue;
    });
  }

  Future<void> deleteTransaction(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _databaseService.deleteTransaction(id);
      await _walletController.refreshWallet();
      return state.requireValue.where((element) => element.id != id).toList();
    });
  }

  Future<void> refreshTransactions() async {
    try {
      final transactions = await _databaseService.getAllTransactions();
      if (state.value != transactions) {
        state = AsyncData(transactions);
      }
    } catch (e) {
      log('Error refreshing transactions: $e');
    }
  }
}

/// Quản lý danh sách tất cả giao dịch với các thao tác CRUD (Tạo, Đọc, Cập nhật, Xóa)
final transactionProvider = AsyncNotifierProvider<TransactionNotifier, List<TransactionModel>>(TransactionNotifier.new);

/// Lưu giữ loại giao dịch hiện được chọn cho mục đích lọc giao diện người dùng
final currentTransactionByTypeProvider = StateProvider<TransactionType?>((ref) => null);

/// Tính tổng số tiền thu nhập từ tất cả giao dịch đã lọc
final totalIncomeProvider = Provider((ref) {
  final transactionAsync = ref.watch(filteredTransactionByDateRangeProvider);
  return transactionAsync.when(
    data:
        (transactions) => transactions
            .where((element) => element.type == TransactionType.income)
            .fold(0.0, (previousValue, curr) => previousValue + curr.amount),
    loading: () => 0.0,
    error: (_, _) => 0.0,
  );
});

/// Tính tổng số tiền chi tiêu từ tất cả giao dịch đã lọc
final totalExpenseProvider = Provider((ref) {
  final transactionsAsync = ref.watch(filteredTransactionByDateRangeProvider);
  return transactionsAsync.when(
    data: (transactions) => transactions.where((t) => t.type == TransactionType.expense).fold(0.0, (prev, curr) => prev + curr.amount),
    loading: () => 0.0,
    error: (_, _) => 0.0,
  );
});

/// Tính số dư ròng bằng cách trừ tổng chi tiêu khỏi tổng thu nhập
final balanceProvider = Provider((ref) {
  final income = ref.watch(totalIncomeProvider);
  final expense = ref.watch(totalExpenseProvider);
  return income - expense;
});

/// Cung cấp giao dịch và tổng số tiền của chúng được lọc theo category ID cụ thể
final transactionByCategoryProvider = Provider.family<AsyncValue<({List<TransactionModel> transactions, double total})>, String>((
  ref,
  categoryId,
) {
  final transactionAsync = ref.watch(filteredTransactionByDateRangeProvider);

  return transactionAsync.whenData((value) {
    final filtered = value.where((element) => element.categoryId == categoryId).toList();
    final total = filtered.fold(0.0, (previousValue, element) => previousValue + element.amount);

    return (transactions: filtered, total: total);
  });
});

/// Lấy tổng số tiền của giao dịch theo category ID từ dữ liệu đã lọc theo ngày
final totalAmountByCategoryProvider = Provider.family<double, String>((ref, categoryId) {
  final transactionAsync = ref.watch(filteredTransactionByDateRangeProvider);
  return transactionAsync.when(
    data:
        (transactions) =>
            transactions.where((element) => element.categoryId == categoryId).fold(0.0, (sum, transaction) => sum + transaction.amount),
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

/// Lọc tất cả giao dịch theo transaction type (thu nhập, chi tiêu, chuyển tiền, v.v.)
final transactionByTypeProvider = Provider.family<AsyncValue<List<TransactionModel>>, TransactionType>((ref, type) {
  final transactionAsync = ref.watch(transactionProvider);
  return transactionAsync.whenData((transactions) => transactions.where((element) => element.type == type).toList());
});

/// Lọc tất cả giao dịch theo ngày cụ thể
final transactionByDateProvider = Provider.family<AsyncValue<List<TransactionModel>>, DateTime>((ref, date) {
  final transactionAsync = ref.watch(transactionProvider);
  return transactionAsync.whenData((value) => value.where((element) => element.date == date).toList());
});

/// Cung cấp transaction + category tương ứng của chúng
final enrichedTransactionProvider = Provider<AsyncValue<List<({TransactionModel transaction, Category? category})>>>((ref) {
  final transactionAsync = ref.watch(filteredTransactionByDateRangeProvider);
  final categoryMapAsync = ref.watch(categoryMapProvider);

  return transactionAsync.whenData((transactions) {
    return categoryMapAsync
        .whenData((categoryMap) {
          return transactions
              .map((transactionData) => (transaction: transactionData, category: categoryMap[transactionData.categoryId]))
              .toList();
        })
        .when(data: (value) => value, error: (error, stackTrace) => [], loading: () => []);
  });
});

/// Lọc giao dịch được làm giàu (có dữ liệu danh mục) theo transaction type
final enrichedTransactionByTypeProvider =
    Provider.family<AsyncValue<List<({TransactionModel transaction, Category? category})>>, TransactionType>((ref, type) {
      final enrichedTransactionAsync = ref.watch(enrichedTransactionProvider);
      return enrichedTransactionAsync.whenData((value) => value.where((element) => element.transaction.type == type).toList());
    });

/// Nhóm thành các category các giao dịch được mã hóa (category, transaction) theo transaction type thành dạng List(category, transaction, total, percentage)
final transactionGroupByCategoryProvider = Provider.family<
  AsyncValue<List<({Category? category, List<TransactionModel> transactions, double total, double percentage})>>,
  TransactionType
>((ref, type) {
  final categoryAsync = ref.watch(enrichedTransactionByTypeProvider(type));
  final totalByType = switch (type) {
    TransactionType.income => ref.watch(totalIncomeProvider),
    TransactionType.expense => ref.watch(totalExpenseProvider),
    _ => ref.watch(totalIncomeProvider),
  };

  return categoryAsync.whenData((enrichedList) {
    final grouped = CollectionUtils.groupBy(enrichedList, (item) => item.category?.id);
    final result =
        grouped.entries.map((entry) {
          final categoryId = entry.key;
          final items = entry.value;

          final transaction = items.map((e) => e.transaction).toList();
          final category = items.first.category;
          final total = items.fold(0.0, (previousValue, element) => previousValue + element.transaction.amount);
          final percentage = totalByType > 0 ? (total / totalByType) * 100 : 0.0;

          return (category: category, transactions: transaction, total: total, percentage: percentage);
        }).toList();

    result.sort((a, b) => b.total.compareTo(a.total));
    return result;
  });
});

final groupPieChartProvider = Provider.family<AsyncValue<Map<String, double>>, TransactionType>((ref, type) {
  final groupAsync = ref.watch(transactionGroupByCategoryProvider(type));
  return groupAsync.whenData((groups) {
    return {for (var group in groups) group.category?.name ?? 'Khác': group.total};
  });
});

/// Nhóm giao dịch được làm giàu theo ngày để hiển thị có tổ chức trong danh sách giao diện
final enrichedTransactionGroupByDateProvider =
    Provider<AsyncValue<Map<DateTime, List<({TransactionModel transaction, Category? category})>>>>((ref) {
      final enrichedTransactionAsync = ref.watch(enrichedTransactionProvider);

      return enrichedTransactionAsync.whenData((enrichedList) {
        return CollectionUtils.groupByAndSort(enrichedList, (item) => DateRangeUtils.dateOnly(item.transaction.date), descending: true);
      });
    });
