import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mosa/models/enums.dart';
import 'package:mosa/providers/date_filter_provider.dart';
import 'package:mosa/providers/transaction_provider.dart';
import 'package:mosa/utils/constants.dart';
import 'package:mosa/utils/helpers.dart';
import 'package:mosa/utils/utils.dart';
import 'package:mosa/screens/overview/widgets/transaction_in_period_time.dart';

import '../../utils/app_colors.dart';

class OverviewScreen extends ConsumerStatefulWidget {
  const OverviewScreen({super.key});

  @override
  ConsumerState<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends ConsumerState<OverviewScreen> {
  @override
  Widget build(BuildContext context) {
    final groupedTransactions = ref.watch(transactionGroupByDateProvider);

    return RefreshIndicator(
      onRefresh: _handleOnRefresh,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: Colors.white),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Lịch sử ghi chép',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  selectDateTypeDropdown(),
                ],
              ),
            ),
            const SizedBox(height: 8),
            overviewDataSection(),
            const SizedBox(height: 8),
            groupedTransactions.when(
              data: (grouped) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: grouped.length,
                  itemBuilder: (context, index) {
                    final date = grouped.keys.elementAt(index);
                    // list transaction item
                    return TransactionInPeriodTime(date: date);
                  },
                );
              },
              error: (_, _) => Center(child: Text('Error')),
              loading: () => CircularProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }

  Widget selectDateTypeDropdown() {
    final dateFilterNotifier = ref.watch(dateRangeFilterProvider);

    return PopupMenuButton(
      initialValue: dateFilterNotifier.name,
      onSelected: (value) {
        ref.read(dateRangeFilterProvider.notifier).state = DateRangeFilter
            .values
            .firstWhere((element) => element.name == value);
      },
      itemBuilder:
          (context) =>
              DateRangeFilter.values.map((e) {
                return PopupMenuItem(
                  value: e.name,
                  child: Text(_getFilterLabel(e)),
                );
              }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(
              _getFilterLabel(dateFilterNotifier),
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }

  Widget overviewDataSection() {
    final totalIncome = ref.watch(totalIncomeProvider);
    final totalExpense = ref.watch(totalExpenseProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Column(
              children: [
                Text('Tổng thu', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  Helpers.formatCurrency(totalIncome),
                  style: TextStyle(
                    color: getTransactionTypeColor(
                      type: TransactionType.income,
                    ),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: AppColors.borderLight,
            width: 1,
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 4),
          ),
          Expanded(
            child: Column(
              children: [
                Text('Tổng chi', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  Helpers.formatCurrency(totalExpense),
                  style: TextStyle(
                    color: getTransactionTypeColor(
                      type: TransactionType.expense,
                    ),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getFilterLabel(DateRangeFilter filter) {
    switch (filter) {
      case DateRangeFilter.week:
        return AppConstants.thisWeek;
      case DateRangeFilter.month:
        return AppConstants.thisMonth;
      case DateRangeFilter.quarter:
        return AppConstants.thisQuarter;
      case DateRangeFilter.year:
        return AppConstants.thisYear;
    }
  }

  Future<void> _handleOnRefresh() async {
    try {
      ref.invalidate(transactionProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }
}
