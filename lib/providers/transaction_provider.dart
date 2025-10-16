import 'package:flutter/material.dart';
import 'package:mosa/services/database_service.dart';

import '../models/transaction.dart';

class TransactionProvider extends ChangeNotifier {
  final DatabaseService databaseService = DatabaseService();

  List<TransactionModel> _transactions = [];

  List<TransactionModel> get transactions => _transactions;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  double get totalIncome {
    return _transactions
        .where((transaction) => transaction.type == 'income')
        .fold(0, (previousValue, element) => previousValue + element.amount);
  }

  double get totalExpense {
    return _transactions
        .where((transaction) => transaction.type == 'outcome')
        .fold(0, (previousValue, element) => previousValue + element.amount);
  }

  double get balance => totalIncome - totalExpense;

  List<TransactionModel> getTransactionModelByType(String type) {
    return _transactions.where((element) => element.type == type).toList();
  }

  // CRUD
  Future<void> loadTransaction() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await databaseService.getAllTransactions();
      print('Loaded ${_transactions.length} transactions');
    } catch (e) {
      print('Error loading transactions: $e');
    } finally {
      _isLoading = true;
      notifyListeners();
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    try{
      final id = await databaseService.insertTransaction(transaction);
      final newTransaction = transaction.copyWith(id: id);
      _transactions.insert(0, newTransaction);
      notifyListeners();
      print('Transaction added with id: $id');
    } catch(e){
      print('Error adding transaction: $e');
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {}

  Future<void> deleteTransaction(int id) async {}
}
