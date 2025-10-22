import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../widgets/category_pie_chart.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            Text('Lịch sử ghi chép'),

          ],),
          CategoryPieChart(categoryData: {'Ăn uống': 300000, 'Xe cộ': 900000, 'Đi chơi': 900000, 'Mua sắm': 980000, 'Khác': 900000}),
          CategoryPieChart(categoryData: {'Ăn uống': 300000, 'Xe cộ': 900000, 'Đi chơi': 900000, 'Mua sắm': 980000, 'Khác': 900000}),
          CategoryPieChart(categoryData: {'Ăn uống': 300000, 'Xe cộ': 900000, 'Đi chơi': 900000, 'Mua sắm': 980000, 'Khác': 900000}),
          CategoryPieChart(categoryData: {'Ăn uống': 300000, 'Xe cộ': 900000, 'Đi chơi': 900000, 'Mua sắm': 980000, 'Khác': 900000}),
          CategoryPieChart(categoryData: {'Ăn uống': 300000, 'Xe cộ': 900000, 'Đi chơi': 900000, 'Mua sắm': 980000, 'Khác': 900000}),
          CategoryPieChart(categoryData: {'Ăn uống': 300000, 'Xe cộ': 900000, 'Đi chơi': 900000, 'Mua sắm': 980000, 'Khác': 900000}),
          CategoryPieChart(categoryData: {'Ăn uống': 300000, 'Xe cộ': 900000, 'Đi chơi': 900000, 'Mua sắm': 980000, 'Khác': 900000}),
          CategoryPieChart(categoryData: {'Ăn uống': 300000, 'Xe cộ': 900000, 'Đi chơi': 900000, 'Mua sắm': 980000, 'Khác': 900000}),
          CategoryPieChart(categoryData: {'Ăn uống': 300000, 'Xe cộ': 900000, 'Đi chơi': 900000, 'Mua sắm': 980000, 'Khác': 900000}),
          CategoryPieChart(categoryData: {'Ăn uống': 300000, 'Xe cộ': 900000, 'Đi chơi': 900000, 'Mua sắm': 980000, 'Khác': 900000}),
          CategoryPieChart(categoryData: {'Ăn uống': 300000, 'Xe cộ': 900000, 'Đi chơi': 900000, 'Mua sắm': 980000, 'Khác': 900000}),
          CategoryPieChart(categoryData: {'Ăn uống': 300000, 'Xe cộ': 900000, 'Đi chơi': 900000, 'Mua sắm': 980000, 'Khác': 900000}),
        ],
      ),
    );
  }
}
