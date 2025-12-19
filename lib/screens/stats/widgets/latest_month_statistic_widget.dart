import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mosa/utils/app_colors.dart';

class LatestMonthStatisticWidget extends StatefulWidget {
  const LatestMonthStatisticWidget({super.key});

  @override
  State<LatestMonthStatisticWidget> createState() =>
      _LatestMonthStatisticWidgetState();
}

class _LatestMonthStatisticWidgetState
    extends State<LatestMonthStatisticWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: InkWell(
        onTap: () {},
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Tình hình thu chi\n',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontSize: 16,
                    ),
                    children: [
                      TextSpan(
                        text: '5 tháng gần nhất',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: null,
                  child: Text(
                    'Xem chi tiết',
                    style: TextStyle(color: AppColors.buttonPrimary),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 80,
                    // width: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceEvenly,
                        // groupsSpace: 15,
                        barGroups: List.generate(5, (index) {
                          return BarChartGroupData(
                            x: 0,
                            barRods: [
                              BarChartRodData(
                                toY: 20,
                                color: AppColors.firstBackGroundColor,
                                rodStackItems: [
                                  BarChartRodStackItem(0, 8, AppColors.expense),
                                  BarChartRodStackItem(8, 15, AppColors.income),
                                ],
                                width: 12,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ],
                          );
                        }),
                        maxY: 25,
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: const FlTitlesData(show: false),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Chi tiêu tháng hiện tại bằng 0, chưa có dự liệu so sánh',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
