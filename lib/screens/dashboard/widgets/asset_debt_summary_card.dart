import 'package:flutter/material.dart';
import 'package:mosa/providers/dashboard_provider.dart';
import 'package:mosa/config/app_colors.dart';
import 'package:mosa/utils/currency_formatter.dart';

class AssetDebtSummaryCard extends StatelessWidget {
  final DashboardData data;

  const AssetDebtSummaryCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tài sản ròng',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              CurrencyFormatter.formatVND(data.netWorth),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: data.netWorth >= 0 ? AppColors.income : AppColors.expense,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    'Tài sản',
                    data.totalAssets,
                    AppColors.income,
                    Icons.account_balance_wallet,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    'Cho vay',
                    data.totalLent,
                    Theme.of(context).colorScheme.primary,
                    Icons.trending_up,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    'Đi vay',
                    data.totalDebt,
                    AppColors.expense,
                    Icons.trending_down,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          CurrencyFormatter.formatNumber(amount),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
