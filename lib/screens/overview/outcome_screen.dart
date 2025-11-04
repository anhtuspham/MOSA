import 'package:flutter/material.dart';

import '../../widgets/category_pie_chart.dart';
import '../../widgets/transaction_category_item.dart';

class OutcomeScreen extends StatefulWidget {
  const OutcomeScreen({super.key});

  @override
  State<OutcomeScreen> createState() => _OutcomeScreenState();
}

class _OutcomeScreenState extends State<OutcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: Colors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tổng chi'),
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
