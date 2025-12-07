import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mosa/providers/category_provider.dart';
import 'package:mosa/utils/helpers.dart';
import 'package:mosa/widgets/error_widget.dart';
import 'package:mosa/widgets/loading_widget.dart';
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
    final transactionGroupState = ref.watch(transactionGroupByDateProvider);
    final totalState = ref.watch(totalByDateProvider(widget.date));
    final categoryAsync = ref.watch(flattenedCategoryProvider);

    final transactionOfDay = transactionGroupState.whenData((group) => group[widget.date] ?? []);

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
              totalState.when(
                data:
                    (totalData) => Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (totalData.income > 0)
                          Text(
                            Helpers.formatCurrency(totalData.income),
                            style: TextStyle(color: AppColors.income, fontSize: 14),
                          ),
                        if (totalData.expense > 0)
                          Text(
                            Helpers.formatCurrency(totalData.expense),
                            style: TextStyle(color: AppColors.expense, fontSize: 14),
                          ),
                      ],
                    ),
                loading: () => CircularProgressIndicator(),
                error: (_, _) => Center(child: Text('Error')),
              ),
            ],
          ),
          const SizedBox(height: 8),
          transactionOfDay.when(
            data: (transactionsData) {
              return categoryAsync.when(
                data: (categories) {
                  final categoryMap = {for (var category in categories) category.id: category};
                  
                  return ListView.builder(
                    itemCount: transactionsData.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final transaction = transactionsData[index];
                      final category = categoryMap[transaction.categoryId];
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
                        walletId: transaction.walletId,
                      );
                    },
                  );
                },
                error: (error, stackTrace) => ErrorSectionWidget(error: error),
                loading: () => LoadingSectionWidget(),
              );
            },
            loading: () => CircularProgressIndicator(),
            error: (error, stackTrace) => Center(child: Text('Error: $error')),
          ),
        ],
      ),
    );
  }
}
