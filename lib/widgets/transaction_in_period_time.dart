import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mosa/widgets/transaction_item.dart';

import '../utils/app_colors.dart';
import '../utils/date_time_extension.dart';

class TransactionInPeriodTime extends StatefulWidget {
  final String typeDate;
  final DateTime date;
  const TransactionInPeriodTime({super.key, this.typeDate = 'day', required this.date});

  @override
  State<TransactionInPeriodTime> createState() => _TransactionInPeriodTimeState();
}

class _TransactionInPeriodTimeState extends State<TransactionInPeriodTime> {
  @override
  Widget build(BuildContext context) {
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
                children: [Text(convertDateTimeToString(widget.date), style: TextStyle(fontWeight: FontWeight.bold)), Text(widget.date.getWeekdayNameBaseCurrent)],
              ),
              Text('478.167đ', style: TextStyle(color: AppColors.expense)),
            ],
          ),
          const SizedBox(height: 8),
          TransactionItem(),
          TransactionItem(),
          TransactionItem(),
          TransactionItem(),
          TransactionItem(),
        ],
      ),
    );
  }
}
