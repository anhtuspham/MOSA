import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mosa/models/enums.dart';
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

/// Provider quản lý loại filter thời gian đang được chọn
///
/// Mặc định: DateRangeFilter.month (lọc theo tháng)
///
/// Sử dụng:
/// ```dart
/// final filter = ref.watch(dateRangeFilterProvider);
/// // Thay đổi filter
/// ref.read(dateRangeFilterProvider.notifier).state = DateRangeFilter.week;
/// ```
final dateRangeFilterProvider = StateProvider<DateRangeFilter>((ref) => DateRangeFilter.month);

final _getDateRangeProvider = Provider<DateTimeRange>((ref) {
  final filter = ref.watch(dateRangeFilterProvider);
  return DateRangeUtils.getRange(filter);
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
  
  return CollectionUtils.groupByAndSort(transactions, (t) => DateRangeUtils.dateOnly(t.date), descending: true);
});

final totalByDateProvider = Provider.family<({double income, double expense}), DateTime>((ref, date) {
  final grouped = ref.watch(transactionGroupByDateProvider);
  final transactions = grouped[date] ?? [];

  return TransactionAggregator.calculatorTotals(transactions);
});
