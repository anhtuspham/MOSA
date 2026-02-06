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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalBalance = ref.watch(totalBalanceWalletProvider);
    return CommonScaffold(
      title: Text('Báo cáo', style: TextStyle(fontWeight: FontWeight.w600)),
      centerTitle: true,
      appBarBackgroundColor: AppColors.background,
      body: SectionContainer(
        // backgroundColor: AppColors.background,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: LinearGradient(
                    colors: [
                      // AppColors.primary,
                      AppColors.third,
                      AppColors.fourth,
                    ],
                    begin: Alignment.centerLeft,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Tài chính hiện tại',
                      style: TextStyle(color: AppColors.textWhite),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Helpers.formatCurrency(totalBalance),
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w600,
                        fontSize: 26,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(child: StatCard()),
                        const SizedBox(width: 10),
                        Expanded(child: StatCard()),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              // Latest statistic month widget
              LatestMonthStatisticWidget(),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}
