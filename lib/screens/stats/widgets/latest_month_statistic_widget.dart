import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/config/app_colors.dart';

class LatestMonthStatisticWidget extends StatefulWidget {
  const LatestMonthStatisticWidget({super.key});

  @override
  State<LatestMonthStatisticWidget> createState() => _LatestMonthStatisticWidgetState();
}

class _LatestMonthStatisticWidgetState extends State<LatestMonthStatisticWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(6)),
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
                    style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
                    children: [
                      TextSpan(
                        text: '5 tháng gần nhất',
                        style: TextStyle(fontWeight: FontWeight.w400, color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => context.pushNamed('dashboard-chart'),
                  child: Text('Xem chi tiết', style: TextStyle(color: AppColors.buttonPrimary)),
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
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Chi tiêu so với tháng 2',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(
                              Icons.arrow_upward_rounded,
                              color: AppColors.expense,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              '26%',
                              style: TextStyle(
                                color: AppColors.expense,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
