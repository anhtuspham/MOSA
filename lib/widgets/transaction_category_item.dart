import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class TransactionCategoryItem extends StatelessWidget {
  const TransactionCategoryItem({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_month),
                    SizedBox(width: 8.w),
                    Expanded(child: Text('Điều chỉnh số dư')),
                    Row(
                      children: [
                        Text('(32.39%)', style: TextStyle(color: Colors.grey[500], fontSize: 11.sp)),
                        const SizedBox(width: 3),
                        Text('117.167 đ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearPercentIndicator(
                  padding: EdgeInsets.zero,
                  lineHeight: 7.0,
                  percent: 0.2,
                  barRadius: Radius.circular(20),
                  progressColor: Colors.red,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[700]),
        ],
      ),
    );
  }
}
