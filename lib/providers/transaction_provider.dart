import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mosa/models/enums.dart';
import 'package:mosa/services/database_service.dart';

import '../models/transaction.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) => DatabaseService());

class TransactionNotifier extends StateNotifier<List<TransactionModel>> {
  final DatabaseService databaseService;
  bool _isLoading = false;

  TransactionNotifier(this.databaseService) : super([]);

  bool get isLoading => _isLoading;

  Future<void> loadTransactions() async {
    _isLoading = true;
    try {
      final transactions = await databaseService.getAllTransactions();
      state = transactions;
      print('Loaded ${state.length} transactions');
    } catch (e) {
      print('Error loading transaction $e');
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      final id = await databaseService.insertTransaction(transaction);
      final newTransaction = transaction.copyWith(id: id);
      state = [newTransaction, ...state];
    } catch (e) {
      log('Error add transaction $e');
      rethrow;
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      await databaseService.updateTransaction(transaction);
      final index = state.indexWhere((element) => element == transaction);
      if (index != -1) {
        state = [...state.sublist(0, index), transaction, ...state.sublist(index + 1)];
      }
    } catch (e) {
      log('Error update transaction $e');
      rethrow;
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await databaseService.deleteTransaction(id);
      state = state.where((element) => element.id != id).toList();
    } catch (e) {
      log('Error deleting transaction $e');
      rethrow;
    }
  }

  Future<void> filterByDateRange(DateTime start, DateTime end) async {
    _isLoading = true;

    try {
      final transactions = await databaseService.getTransactionsByDateRange(start, end);
      state = transactions;
    } catch (e) {
      print('❌ Error filtering transactions: $e');
      rethrow;
    } finally {
      _isLoading = false;
    }
  }
}

final transactionProvider = StateNotifierProvider<TransactionNotifier, List<TransactionModel>>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return TransactionNotifier(databaseService);
});

final totalIncomeProvider = Provider((ref) {
  final transaction = ref.watch(transactionProvider);
  return transaction
      .where((element) => element.type == TransactionType.income)
      .fold(0.0, (previousValue, element) => previousValue + element.amount);
});

final totalExpenseProvider = Provider((ref) {
  final transactions = ref.watch(transactionProvider);
  return transactions.where((t) => t.type == TransactionType.outcome).fold(0.0, (prev, curr) => prev + curr.amount);
});

final balanceProvider = Provider((ref) {
  final income = ref.watch(totalIncomeProvider);
  final expense = ref.watch(totalExpenseProvider);
  return income - expense;
});

final transactionByTypeProvider = Provider.family<List<TransactionModel>, TransactionType>((ref, type) {
  final transaction = ref.watch(transactionProvider);
  return transaction.where((element) => element.type == type).toList();
});

final transactionsInitialLoadProvider = FutureProvider<void>((ref) async {
  await ref.read(transactionProvider.notifier).loadTransactions();
});

// class TransactionProvider extends ChangeNotifier {
//   final DatabaseService databaseService = DatabaseService();
//
//   List<TransactionModel> _transactions = [];
//
//   List<TransactionModel> get transactions => _transactions;
//
//   bool _isLoading = false;
//
//   bool get isLoading => _isLoading;
//
//   double get totalIncome {
//     return _transactions
//         .where((transaction) => transaction.type == TransactionType.income)
//         .fold(0, (previousValue, element) => previousValue + element.amount);
//   }
//
//   double get totalExpense {
//     return _transactions
//         .where((transaction) => transaction.type == TransactionType.outcome)
//         .fold(0, (previousValue, element) => previousValue + element.amount);
//   }
//
//   double get balance => totalIncome - totalExpense;
//
//   List<TransactionModel> getTransactionModelByType(TransactionType type) {
//     return _transactions.where((element) => element.type == type).toList();
//   }
//
//   // CRUD
//   Future<void> loadTransaction() async {
//     _isLoading = true;
//     notifyListeners();
//
//     try {
//       _transactions = await databaseService.getAllTransactions();
//       print('Loaded ${_transactions.length} transactions');
//     } catch (e) {
//       print('Error loading transactions: $e');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   Future<void> addTransaction(TransactionModel transaction) async {
//     try{
//       final id = await databaseService.insertTransaction(transaction);
//       final newTransaction = transaction.copyWith(id: id);
//       _transactions.insert(0, newTransaction);
//       notifyListeners();
//       log('Transaction added with id: $id');
//     } catch(e){
//       log('Error adding transaction: $e');
//       rethrow;
//     }
//   }
//
//   Future<void> updateTransaction(TransactionModel transaction) async {
//     try{
//       await databaseService.updateTransaction(transaction);
//       final index = _transactions.indexWhere((element) => element.id == transaction.id);
//       if(index != -1){
//         _transactions[index] = transaction;
//         notifyListeners();
//       }
//     } catch(e){
//       print('Error update transaction $e');
//       rethrow;
//     }
//   }
//
//   Future<void> deleteTransaction(int id) async {
//     try{
//       await databaseService.deleteTransaction(id);
//       _transactions.removeWhere((element) => element.id == id);
//       notifyListeners();
//     } catch(e){
//       print('Error deleting transaction $e');
//       rethrow;
//     }
//   }
//
//   Future<void> filterByDateRange(DateTime start, DateTime end) async {
//     _isLoading = true;
//     notifyListeners();
//
//     try {
//       _transactions = await databaseService.getTransactionsByDateRange(start, end);
//     } catch (e) {
//       print('❌ Error filtering transactions: $e');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
// }
