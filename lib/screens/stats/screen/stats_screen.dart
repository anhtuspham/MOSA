import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/router/app_routes.dart';
import 'package:mosa/screens/stats/widgets/latest_month_statistic_widget.dart';
import 'package:mosa/config/app_colors.dart';
import 'package:mosa/utils/helpers.dart';
import 'package:mosa/utils/toast.dart';
import 'package:mosa/widgets/section_container.dart';
import 'package:mosa/widgets/stat_card.dart';
import 'package:mosa/widgets/common_scaffold.dart';

import '../../../providers/wallet_provider.dart';

class StatsShellScreen extends ConsumerWidget {
  const StatsShellScreen({super.key});

  Widget _buildGridItem(BuildContext context, IconData icon, String label, Color iconColor, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () => showInfoToast('Tính năng đang trong giai đoạn phát triển.'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalBalance = ref.watch(totalBalanceWalletProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return CommonScaffold.single(
      title: const Text('Báo cáo', style: TextStyle(fontWeight: FontWeight.w600)),
      centerTitle: true,
      appBarBackgroundColor: Theme.of(context).colorScheme.surface,
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
                  gradient: LinearGradient(
                    // colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                    colors: [colorScheme.secondaryContainer, colorScheme.onPrimaryFixed],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Tài chính hiện tại',
                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Helpers.formatCurrency(totalBalance),
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
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
                  _buildGridItem(
                    context,
                    Icons.receipt_long,
                    'Theo dõi vay nợ',
                    AppColors.primaryBlue,
                    onTap: () => context.push(AppRoutes.loanTracking),
                  ),
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
