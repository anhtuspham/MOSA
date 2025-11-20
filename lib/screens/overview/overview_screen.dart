import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mosa/providers/date_filter_provider.dart';
import 'package:mosa/providers/transaction_provider.dart';
import 'package:mosa/widgets/transaction_in_period_time.dart';
import 'package:provider/provider.dart';

import '../../utils/app_colors.dart';

class OverviewScreen extends ConsumerStatefulWidget {
  const OverviewScreen({super.key});

  @override
  ConsumerState<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends ConsumerState<OverviewScreen> {
  @override
  Widget build(BuildContext context) {
    final selectedMonth = context.watch<DateFilterProvider>().selectedMonth;
    final totalIncome = ref.watch(totalIncomeProvider);
    final totalExpense = ref.watch(totalExpenseProvider);
    final transactionNotifier = ref.watch(transactionProvider);

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
                  Text('Lịch sử ghi chép', style: TextStyle(fontWeight: FontWeight.bold)),
                  PopupMenuButton(
                    initialValue: selectedMonth,
                    onSelected: (value) {
                      context.read<DateFilterProvider>().setMonth(value);
                    },
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(value: 'Tuần này', child: Text('Tuần này')),
                          PopupMenuItem(value: 'Tháng này', child: Text('Tháng này')),
                          PopupMenuItem(value: 'Năm nay', child: Text('Năm nay')),
                        ],
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Text(selectedMonth, style: TextStyle(fontWeight: FontWeight.w500)),
                          const Icon(Icons.keyboard_arrow_down),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
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
                          '$totalIncomeđ',
                          style: TextStyle(color: AppColors.income, fontSize: 18, fontWeight: FontWeight.w500),
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
                          '$totalExpense',
                          style: TextStyle(color: AppColors.expense, fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TransactionInPeriodTime(date: DateTime.now()),
            TransactionInPeriodTime(date: DateTime.now()),
            TransactionInPeriodTime(date: DateTime.now().subtract(Duration(days: 1))),
            TransactionInPeriodTime(date: DateTime.now().subtract(Duration(days: 2))),
          ],
        ),
      ),
    );
  }

  Future<void> _handleOnRefresh() async {
    try {
      ref.read(transactionProvider.notifier).loadTransactions();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }
}
