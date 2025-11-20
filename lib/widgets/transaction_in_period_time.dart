import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mosa/providers/transaction_provider.dart';
import 'package:mosa/widgets/transaction_item.dart';

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
    final transactionNotifier = ref.watch(transactionProvider);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 16),
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
                  Text(widget.date.getWeekdayNameBaseCurrent),
                ],
              ),
              Text('478.167đ', style: TextStyle(color: AppColors.expense)),
            ],
          ),
          const SizedBox(height: 8),
          ListView.builder(
            itemCount: transactionNotifier.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final transaction = transactionNotifier[index];
              return TransactionItem(
                category: transaction.category,
                amount: transaction.amount,
                note: transaction.note,
                wallet: transaction.wallet,
              );
            },
          ),
          // TransactionItem(),
          // TransactionItem(),
          // TransactionItem(),
          // TransactionItem(),
          // TransactionItem(),
        ],
      ),
    );
  }
}
