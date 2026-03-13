import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mosa/models/enums.dart';
import 'package:mosa/providers/transaction_provider.dart';

import 'package:mosa/utils/currency_formatter.dart';

class ExpensePieChart extends ConsumerWidget {
  const ExpensePieChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Reuse the existing pie chart provider
    final pieDataAsync = ref.watch(groupPieChartProvider(TransactionType.expense));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cơ cấu chi tiêu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 24),
            pieDataAsync.when(
              data: (dataMap) {
                if (dataMap.isEmpty || dataMap.values.every((v) => v <= 0)) {
                  return SizedBox(
                    height: 200,
                    child: Center(
                      child: Text(
                        'Chưa có dữ liệu chi tiêu',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ),
                  );
                }

                // Create a color palette for the pie chart slices
                final colors = [
                  const Color(0xFFF44336), // Red
                  const Color(0xFFFF9800), // Orange
                  const Color(0xFFFFC107), // Amber
                  const Color(0xFF4CAF50), // Green
                  const Color(0xFF00BCD4), // Cyan
                  const Color(0xFF3F51B5), // Indigo
                  const Color(0xFF9C27B0), // Purple
                  const Color(0xFF795548), // Brown
                  const Color(0xFF607D8B), // Blue Grey
                ];

                int colorIndex = 0;
                final total = dataMap.values.fold(0.0, (sum, val) => sum + val);

                final pieSections = dataMap.entries.map((entry) {
                  final value = entry.value;
                  final percentage = total > 0 ? (value / total) * 100 : 0;
                  final color = colors[colorIndex % colors.length];
                  colorIndex++;

                  return PieChartSectionData(
                    color: color,
                    value: value,
                    title: percentage > 5 ? '${percentage.toStringAsFixed(1)}%' : '',
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList();

                return Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: pieSections,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Legend
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: dataMap.entries.map((entry) {
                        final idx = dataMap.keys.toList().indexOf(entry.key);
                        return _buildIndicator(
                          context,
                          color: colors[idx % colors.length],
                          text: entry.key,
                          value: entry.value,
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => SizedBox(
                height: 200,
                child: Center(
                  child: Text('Lỗi: $err'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(
    BuildContext context, {
    required Color color,
    required String text,
    required double value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface),
        ),
        const SizedBox(width: 4),
        Text(
          '(${CurrencyFormatter.formatNumber(value)})',
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
