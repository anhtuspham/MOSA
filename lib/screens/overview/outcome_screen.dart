import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosa/models/enums.dart';
import 'package:mosa/utils/helpers.dart';
import 'package:mosa/widgets/error_widget.dart';
import 'package:mosa/widgets/loading_widget.dart';

import '../../providers/transaction_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/category_pie_chart.dart';
import '../../widgets/progress_info_item.dart';

class OutcomeScreen extends ConsumerStatefulWidget {
  const OutcomeScreen({super.key});

  @override
  ConsumerState<OutcomeScreen> createState() => _OutcomeScreenState();
}

class _OutcomeScreenState extends ConsumerState<OutcomeScreen> {
  @override
  Widget build(BuildContext context) {
    final totalExpense = ref.watch(totalExpenseProvider);
    final groupCategoryAsync = ref.watch(transactionGroupByCategoryProvider(TransactionType.expense));
    final pieChartAsync = ref.watch(groupPieChartProvider(TransactionType.expense));

    return RefreshIndicator(
      onRefresh: _handleOnRefresh,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: Colors.white),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('Tổng chi'), Text(Helpers.formatCurrency(totalExpense), style: TextStyle(fontWeight: FontWeight.bold))],
              ),
            ),
            pieChartAsync.when(
              data: (chartData) {
                return CategoryPieChart(categoryData: chartData);
              },
              error: (error, stackTrace) => ErrorSectionWidget(error: error),
              loading: () => LoadingSectionWidget(),
            ),
            groupCategoryAsync.when(
              data: (groupData) {
                return Column(
                  children:
                      groupData.asMap().entries.map((entry) {
                        final index = entry.key;
                        final group = entry.value;

                        return ProgressInfoItem(
                          leadingIcon: group.category?.getIcon() ?? Icon(Icons.help),
                          title: Text(group.category?.name ?? ''),
                          currentProgress: group.percentage / 100,
                          linearColors: AppColors.chartColors[index % AppColors.chartColors.length],
                          trailing: Row(
                            children: [
                              Text('(${group.percentage.toStringAsFixed(2)}%)', style: TextStyle(color: Colors.grey[500], fontSize: 11.sp)),
                              const SizedBox(width: 3),
                              Text(Helpers.formatCurrency(group.total), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                            ],
                          ),
                        );
                      }).toList(),
                );
              },
              error: (error, stackTrace) => ErrorSectionWidget(error: error),
              loading: () => LoadingSectionWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleOnRefresh() async {
    try {
      ref.invalidate(totalExpenseProvider);
      ref.invalidate(transactionGroupByCategoryProvider(TransactionType.expense));
      ref.invalidate(groupPieChartProvider(TransactionType.expense));
    } catch (e, str) {
      log('Error on refresh: $e', error: e, stackTrace: str, name: 'OutcomeScreen');
    }
  }
}
