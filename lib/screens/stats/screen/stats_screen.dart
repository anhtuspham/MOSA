import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mosa/screens/stats/widgets/latest_month_statistic_widget.dart';
import 'package:mosa/utils/app_colors.dart';
import 'package:mosa/utils/helpers.dart';
import 'package:mosa/widgets/section_container.dart';
import 'package:mosa/widgets/stat_card.dart';
import 'package:mosa/widgets/common_scaffold.dart';

import '../../../providers/wallet_provider.dart';

class StatsShellScreen extends ConsumerWidget {
  const StatsShellScreen({super.key});

  Widget _buildGridItem(BuildContext context, IconData icon, String label, Color iconColor, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLighter.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalBalance = ref.watch(totalBalanceWalletProvider);
    return CommonScaffold(
      title: const Text('Báo cáo', style: TextStyle(fontWeight: FontWeight.w600)),
      centerTitle: true,
      appBarBackgroundColor: AppColors.background,
      body: SectionContainer(
        // backgroundColor: AppColors.background,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Tài chính hiện tại', style: TextStyle(color: AppColors.textWhite, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(
                      Helpers.formatCurrency(totalBalance),
                      style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 28),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(child: StatCard(title: 'Tổng có', amount: Helpers.formatCurrency(totalBalance))),
                        const SizedBox(width: 12),
                        Expanded(child: StatCard(title: 'Tổng nợ', amount: Helpers.formatCurrency(0))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Latest statistic month widget
              const LatestMonthStatisticWidget(),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.8,
                children: [
                  _buildGridItem(context, Icons.trending_up, 'Phân tích chi tiêu', AppColors.primaryBlue),
                  _buildGridItem(context, Icons.trending_down, 'Phân tích thu', AppColors.primaryBlue),
                  _buildGridItem(context, Icons.receipt_long, 'Theo dõi vay nợ', AppColors.primaryBlue),
                  _buildGridItem(context, Icons.people_alt_outlined, 'Đối tượng thu/chi', AppColors.primaryBlue),
                  _buildGridItem(context, Icons.calendar_today_outlined, 'Chuyến đi/Sự kiện', AppColors.primaryBlue),
                  _buildGridItem(
                    context,
                    Icons.account_balance_wallet_outlined,
                    'Phân tích tài chính',
                    AppColors.primaryBlue,
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
