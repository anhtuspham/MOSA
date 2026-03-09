import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mosa/providers/budget_provider.dart';
import 'package:mosa/providers/category_provider.dart';
import 'package:mosa/utils/app_colors.dart';
import 'package:mosa/utils/currency_formatter.dart';

class BudgetProgressCard extends ConsumerWidget {
  final BudgetProgress progress;

  const BudgetProgressCard({super.key, required this.progress});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryMapProvider);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: categoriesAsync.when(
          data: (categoryMap) {
            final category = categoryMap[progress.budget.categoryId];
            final categoryName = category?.name ?? 'Không xác định';

            Color progressColor = AppColors.success;
            if (progress.percentage >= 0.8) {
              progressColor = AppColors.error; // Red
            } else if (progress.percentage >= 0.5) {
              progressColor = AppColors.warning; // Orange
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Replace with Category Icon when available, using placeholder circle for now
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.getCategoryColor(categoryName).withOpacity(0.2),
                          ),
                          child: Icon(Icons.category, color: AppColors.getCategoryColor(categoryName), size: 16),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          categoryName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${(progress.percentage * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: progressColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: progress.percentage > 1.0 ? 1.0 : progress.percentage,
                  backgroundColor: AppColors.borderLighter,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Đã chi',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        Text(
                          CurrencyFormatter.formatNumber(progress.spentAmount),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Ngân sách',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        Text(
                          CurrencyFormatter.formatNumber(progress.budget.amount),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (progress.isOverBudget) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Đã vượt ngân sách ${CurrencyFormatter.formatNumber(progress.spentAmount - progress.budget.amount)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                  Text(
                    'Còn lại ${CurrencyFormatter.formatNumber(progress.remaining)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.success,
                    ),
                  ),
                ]
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Lỗi: $err'),
        ),
      ),
    );
  }
}
