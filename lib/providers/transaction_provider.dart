import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mosa/models/enums.dart';
import 'package:mosa/providers/date_filter_provider.dart';
import 'package:mosa/services/database_service.dart';

import '../models/transaction.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) => DatabaseService());

class TransactionNotifier extends AsyncNotifier<List<TransactionModel>> {
  @override
  Future<List<TransactionModel>> build() async {
    return await _databaseService.getAllTransactions();
  }

  DatabaseService get _databaseService => ref.read(databaseServiceProvider);

  Future<void> addTransaction(TransactionModel transaction) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final id = await _databaseService.insertTransaction(transaction);
      final newTransaction = transaction.copyWith(id: id);
      return [newTransaction, ...state.requireValue];
    });
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _databaseService.updateTransaction(transaction);
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
      return state.requireValue.where((element) => element.id != id).toList();
    });
  }

  Future<void> filterByDateRange(DateTime start, DateTime end) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return await _databaseService.getTransactionsByDateRange(start, end);
    });
  }
}

final transactionProvider = AsyncNotifierProvider<TransactionNotifier, List<TransactionModel>>(TransactionNotifier.new);

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

final totalExpenseProvider = Provider((ref) {
  final transactionsAsync = ref.watch(filteredTransactionByDateRangeProvider);
  return transactionsAsync.when(
    data:
        (transactions) =>
            transactions.where((t) => t.type == TransactionType.expense).fold(0.0, (prev, curr) => prev + curr.amount),
    loading: () => 0.0,
    error: (_, _) => 0.0,
  );
});

final balanceProvider = Provider((ref) {
  final income = ref.watch(totalIncomeProvider);
  final expense = ref.watch(totalExpenseProvider);
  return income - expense;
});

final transactionByTypeProvider = Provider.family<AsyncValue<List<TransactionModel>>, TransactionType>((ref, type) {
  final transactionAsync = ref.watch(transactionProvider);
  return transactionAsync.whenData((transactions) => transactions.where((element) => element.type == type).toList());
});

final transactionByDateProvider = Provider.family<AsyncValue<List<TransactionModel>>, DateTime>((ref, date) {
  final transactionAsync = ref.watch(transactionProvider);
  return transactionAsync.whenData((value) => value.where((element) => element.date == date).toList());
});

final currentTransactionByTypeProvider = StateProvider<TransactionType?>((ref) => null);
