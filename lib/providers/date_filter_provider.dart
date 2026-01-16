import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mosa/models/transaction.dart';
import 'package:mosa/providers/transaction_provider.dart';
import 'package:mosa/utils/collection_utils.dart';
import 'package:mosa/utils/date_utils.dart';
import 'package:mosa/utils/transaction_utils.dart';

/// Enum định nghĩa các loại khoảng thời gian để filter transactions
/// - week: Lọc theo tuần (từ thứ 2 đến hôm nay)
/// - month: Lọc theo tháng hiện tại
/// - quarter: Lọc theo quý hiện tại
/// - year: Lọc theo năm hiện tại
enum DateRangeFilter { week, month, quarter, year }

final dateRangeFilterProvider = StateProvider<DateRangeFilter>(
    (ref) => DateRangeFilter.month,
);

final _getDateRangeProvider = Provider<DateTimeRange>((ref) {
  final filter = ref.watch(dateRangeFilterProvider);
  return DateRangeUtils.getRange(filter);
});

final filteredTransactionByDateRangeProvider =
    Provider<AsyncValue<List<TransactionModel>>>((ref) {
      final transactions = ref.watch(transactionProvider);
      final dateRange = ref.watch(_getDateRangeProvider);

      final filtered = transactions.whenData(
        (transaction) =>
            transaction.where((element) {
              return element.date.isAfter(dateRange.start) &&
                  element.date.isBefore(dateRange.end);
            }).toList(),
      );

      filtered.whenData((filterData) {
        filterData.sort((a, b) => b.date.compareTo(a.date));
        return filterData;
      });
      return filtered;
    });

final transactionGroupByDateProvider =
    Provider<AsyncValue<Map<DateTime, List<TransactionModel>>>>((ref) {
      final transactionAsync = ref.watch(
        filteredTransactionByDateRangeProvider,
      );

      return transactionAsync.whenData((transactions) {
        return CollectionUtils.groupByAndSort(
          transactions,
          (t) => DateRangeUtils.dateOnly(t.date),
          descending: true,
        );
      });
    });

final totalByDateProvider =
    Provider.family<AsyncValue<({double income, double expense})>, DateTime>((
      ref,
      date,
    ) {
      final groupedAsync = ref.watch(transactionGroupByDateProvider);
      return groupedAsync.whenData((grouped) {
        final transactions = grouped[date] ?? [];

        return TransactionAggregator.calculatorTotals(transactions);
      });
    });
