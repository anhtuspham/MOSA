import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mosa/widgets/transaction_category_item.dart';

import '../../widgets/category_pie_chart.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Column(children: [
      Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: Colors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tổng thu'),
            Text('892.167 đ'),
          ],
        ),
      ),
      CategoryPieChart(categoryData: {'Ăn uống': 300000, 'Xe cộ': 900000, 'Đi chơi': 900000, 'Mua sắm': 980000, 'Khác': 900000,},),
      TransactionCategoryItem(),
      TransactionCategoryItem(),
      TransactionCategoryItem(),
    ],);
  }
}
