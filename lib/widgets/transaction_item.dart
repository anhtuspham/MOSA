import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../utils/app_colors.dart';

class TransactionItem extends StatelessWidget {
  const TransactionItem({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month),
          SizedBox(width: 8.w),
          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Điều chỉnh số dư'),
              Text('Điều chỉnh số dư chuyển khoản', style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary),)
            ],
          )),
          Column(
            children: [
              Text('117.167 đ', style: TextStyle(fontSize: 16.sp, color: AppColors.expense)),
              Row(children: [
                Icon(Icons.wallet, size: 16.sp,),
                const SizedBox(width: 4),
                Text('Zalopay', style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary),)
              ],)
            ],
          ),
        ],
      ),
    );
  }
}
