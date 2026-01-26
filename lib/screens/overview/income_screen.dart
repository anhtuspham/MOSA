import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosa/models/enums.dart';
import 'package:mosa/utils/app_colors.dart';
import 'package:mosa/utils/helpers.dart';
import 'package:mosa/utils/toast.dart';
import 'package:mosa/widgets/error_widget.dart';
import 'package:mosa/widgets/loading_widget.dart';
import 'package:mosa/widgets/progress_info_item.dart';

import '../../providers/transaction_provider.dart';
import '../../widgets/category_pie_chart.dart';

class IncomeScreen extends ConsumerStatefulWidget {
  const IncomeScreen({super.key});

  @override
  ConsumerState<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends ConsumerState<IncomeScreen> {
  @override
  Widget build(BuildContext context) {
    final totalIncome = ref.watch(totalIncomeProvider);
    final groupByCategoryAsync = ref.watch(transactionGroupByCategoryProvider(TransactionType.income));
    final pieChartAsync = ref.watch(groupPieChartProvider(TransactionType.income));

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
                children: [Text('Tổng thu'), Text(Helpers.formatCurrency(totalIncome), style: TextStyle(fontWeight: FontWeight.bold))],
              ),
            ),
            pieChartAsync.when(
              data: (chartData) {
                return CategoryPieChart(categoryData: chartData);
              },
              error: (error, stackTrace) => ErrorSectionWidget(error: error),
              loading: () => LoadingSectionWidget(),
            ),
            groupByCategoryAsync.when(
              data: (categoryGroup) {
                return Column(
                  children:
                      categoryGroup.asMap().entries.map((entry) {
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
                          actionIcon: Icons.arrow_forward_ios_rounded,
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
      ref.invalidate(totalIncomeProvider);
      ref.invalidate(transactionGroupByCategoryProvider(TransactionType.income));
      ref.invalidate(groupPieChartProvider(TransactionType.income));
    } catch (e) {
      showResultToast('Lỗi khi tải trang', isError: true);
    }
  }
}
