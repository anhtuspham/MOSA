import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosa/widgets/progress_info_item.dart';

import '../../widgets/category_pie_chart.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: Colors.white),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('Tổng thu'), Text('892.167 đ')],
          ),
        ),
        CategoryPieChart(
          categoryData: {
            'Ăn uống': 300000,
            'Xe cộ': 900000,
            'Đi chơi': 900000,
            'Mua sắm': 980000,
            'Khác': 900000,
          },
        ),
        ProgressInfoItem(
          leadingIcon: Icon(Icons.calendar_month),
          title: Text('Điều chỉnh số dư'),
          currentProgress: 0.2,
          trailing: Row(
            children: [
              Text(
                '(32.39%)',
                style: TextStyle(color: Colors.grey[500], fontSize: 11.sp),
              ),
              const SizedBox(width: 3),
              Text(
                '117.167 đ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
              ),
            ],
          ),
        ),
        ProgressInfoItem(
          leadingIcon: Icon(Icons.calendar_month),
          title: Text('Điều chỉnh số dư'),
          currentProgress: 0.2,
          trailing: Row(
            children: [
              Text(
                '(32.39%)',
                style: TextStyle(color: Colors.grey[500], fontSize: 11.sp),
              ),
              const SizedBox(width: 3),
              Text(
                '117.167 đ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
              ),
            ],
          ),
        ),
        ProgressInfoItem(
          leadingIcon: Icon(Icons.calendar_month),
          title: Text('Điều chỉnh số dư'),
          currentProgress: 0.2,
          trailing: Row(
            children: [
              Text(
                '(32.39%)',
                style: TextStyle(color: Colors.grey[500], fontSize: 11.sp),
              ),
              const SizedBox(width: 3),
              Text(
                '117.167 đ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
