import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mosa/providers/category_provider.dart';
import 'package:mosa/utils/helpers.dart';
import 'package:mosa/widgets/transaction_item.dart';

import '../providers/date_filter_provider.dart';
import '../utils/app_colors.dart';
import '../utils/date_time_extension.dart';

/// Ghi chép thu chi trong 1 đơn vị thời gian
class TransactionInPeriodTime extends ConsumerStatefulWidget {
  final String typeDate;
  final DateTime date;

  const TransactionInPeriodTime({super.key, this.typeDate = 'day', required this.date});

  @override
  ConsumerState<TransactionInPeriodTime> createState() => _TransactionInPeriodTimeState();
}

class _TransactionInPeriodTimeState extends ConsumerState<TransactionInPeriodTime> {
  @override
  Widget build(BuildContext context) {
    final groupedNotifier = ref.watch(transactionGroupByDateProvider);
    final totals = ref.watch(totalByDateProvider(widget.date));

    final transactionOfDay = groupedNotifier[widget.date] ?? [];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(convertDateTimeToString(widget.date), style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(widget.date.weekdayLabel),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (totals.income > 0)
                    Text(
                      Helpers.formatCurrency(totals.income),
                      style: TextStyle(color: AppColors.income, fontSize: 14),
                    ),
                  if (totals.expense > 0)
                    Text(
                      Helpers.formatCurrency(totals.expense),
                      style: TextStyle(color: AppColors.expense, fontSize: 14),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListView.builder(
            itemCount: transactionOfDay.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final transaction = transactionOfDay[index];
              final categoryAsync = ref.watch(categoryByIdProvider(transaction.categoryId));

              return categoryAsync.when(
                data: (category) {
                  if (category == null) {
                    return Container(
                      height: 60,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                      child: const Center(child: Text('Category not found')),
                    );
                  }
                  return TransactionItem(
                    category: category,
                    amount: transaction.amount,
                    note: transaction.note,
                    wallet: transaction.wallet,
                  );
                },
                loading:
                    () => Container(
                      height: 60,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                error:
                    (error, stack) => Container(
                      height: 60,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(color: Colors.red[100], borderRadius: BorderRadius.circular(10)),
                      child: Center(child: Text('Error: ${error.toString()}')),
                    ),
              );
            },
          ),
        ],
      ),
    );
  }
}
