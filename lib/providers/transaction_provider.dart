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

  // CRUD
  Future<void> loadTransaction() async{}

  Future<void> addTransaction(TransactionModel transaction) async{}

  Future<void> updateTransaction(TransactionModel transaction) async{}

  Future<void> deleteTransaction(int id) async{}
}
