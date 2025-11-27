import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosa/models/category.dart';
import 'package:mosa/utils/helpers.dart';
import '../utils/app_colors.dart';

class TransactionItem extends StatelessWidget {
  final Category category;
  final String? note;
  final double amount;
  final String wallet;

  const TransactionItem({super.key, required this.category, this.note, required this.amount, required this.wallet});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          category.getIcon(),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.name),
                if (note != null)
                  Text(
                    note!,
                    style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
          Column(
            children: [
              Text(Helpers.formatCurrency(amount), style: TextStyle(fontSize: 16.sp, color: AppColors.expense)),
              Row(
                children: [
                  Icon(Icons.wallet, size: 16.sp),
                  const SizedBox(width: 4),
                  Text(wallet, style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
