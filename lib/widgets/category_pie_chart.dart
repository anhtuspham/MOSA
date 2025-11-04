import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mosa/utils/app_colors.dart';
import 'package:mosa/utils/constants.dart';
import 'package:mosa/utils/utils.dart';

/// Biểu đồ hình tròn thể hiện tỷ lệ các danh mục
class CategoryPieChart extends StatelessWidget {
  final Map<String, double> categoryData;

  const CategoryPieChart({super.key, required this.categoryData});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            height: size.height * 0.15,
            width: size.width * 0.4,
            child: PieChart(PieChartData(sections: _buildSection(), centerSpaceRadius: 20, sectionsSpace: 1, borderData: FlBorderData(show: false))),
          ),
          const SizedBox(width: 10),
          Expanded(child: _buildLegend()),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSection() {
    return categoryData.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;

      return PieChartSectionData(value: data.value, showTitle: false, color: AppColors.chartColors[index]);
    }).toList();
  }

  Widget _buildLegend() {
    double total = categoryData.values.fold(0, (sum, value) => sum + value);
    double maxCategoryWidth = 0;
    for (var element in categoryData.entries) {
      final textPainter = getTextPainter(element.key);
      maxCategoryWidth = max(maxCategoryWidth, textPainter.width);
    }

    return Column(
      children:
          categoryData.entries.toList().asMap().entries.map((e) {
            final index = e.key;
            final data = e.value;
            final percentage = (data.value / total) * 100;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(2), color: AppColors.chartColors[index]),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(width: maxCategoryWidth * AppConstants.scaleTextFactor, child: Text(data.key, overflow: TextOverflow.ellipsis, style: TextStyle
                    (fontSize: 14))),
                  const SizedBox(width: 8),
                  Text('${percentage.toStringAsFixed(2)}%', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }).toList(),
    );
  }
}
