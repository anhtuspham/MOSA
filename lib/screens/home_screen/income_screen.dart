import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:mosa/widgets/transaction_item.dart';

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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tổng chi'),
            Text('892.167 đ'),
          ],
        ),
      ),
      SizedBox(
        height: size.height * 0.15,
        child: PieChart(
          PieChartData(
            centerSpaceRadius: 30,
            sections: [
              PieChartSectionData(value: 10, showTitle: true),
              PieChartSectionData(value: 20),
              PieChartSectionData(value: 10),
              PieChartSectionData(value: 10),
            ]
          ),

        ),
      ),
      TransactionItem(),
      TransactionItem(),
      TransactionItem(),
    ],);
  }
}
