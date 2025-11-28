import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mosa/models/enums.dart';
import 'package:mosa/models/transaction.dart';
import 'package:mosa/providers/transaction_provider.dart';

enum DateRangeFilter { week, month, quarter, year }

final dateRangeFilterProvider = StateProvider<DateRangeFilter>((ref) => DateRangeFilter.month);

final _getDateRangeProvider = Provider<DateTimeRange>((ref) {
  final filter = ref.watch(dateRangeFilterProvider);
  final now = DateTime.now();
  switch (filter) {
    case DateRangeFilter.week:
      final monday = now.subtract(Duration(days: now.weekday - 1));
      return DateTimeRange(
        start: DateTime(monday.year, monday.month, monday.day),
        end: DateTime(now.year, now.month, now.day),
      );
    case DateRangeFilter.month:
      return DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: DateTime(now.year, now.month + 1, 1).subtract(Duration(seconds: 1)),
      );
    case DateRangeFilter.quarter:
      final quarter = (now.month - 1) ~/ 3;
      return DateTimeRange(
        start: DateTime(now.year, quarter * 3 + 1, 1),
        end: DateTime(now.year, quarter * 3 + 4).subtract(Duration(seconds: 1)),
      );
    case DateRangeFilter.year:
      return DateTimeRange(
        start: DateTime(now.year, 1, 1),
        end: DateTime(now.year + 1, 1, 1).subtract(Duration(seconds: 1)),
      );
  }
});

final filteredTransactionByDateRangeProvider = Provider<List<TransactionModel>>((ref) {
  final transactions = ref.watch(transactionProvider);
  final dateRange = ref.watch(_getDateRangeProvider);

  final filtered =
      transactions.where((element) {
        return element.date.isAfter(dateRange.start) && element.date.isBefore(dateRange.end);
      }).toList();

  filtered.sort((a, b) => a.date.compareTo(b.date));
  return filtered;
});

final transactionGroupByDateProvider = Provider<Map<DateTime, List<TransactionModel>>>((ref) {
  final transactions = ref.watch(filteredTransactionByDateRangeProvider);
  final grouped = <DateTime, List<TransactionModel>>{};

  for (var transaction in transactions) {
    final dateKey = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);
    if (grouped.containsKey(dateKey)) {
      grouped[dateKey]!.add(transaction);
    } else {
      grouped[dateKey] = [transaction];
    }
  }

  final sortedKey = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
  return Map.fromEntries(sortedKey.map((e) => MapEntry(e, grouped[e]!)));
});

final totalByDateProvider = Provider.family<({double income, double expense}), DateTime>((ref, date) {
  final grouped = ref.watch(transactionGroupByDateProvider);
  final transactions = grouped[date] ?? [];

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
});
