import 'package:flutter/material.dart';
import 'package:mosa/screens/stats/widgets/latest_month_statistic_widget.dart';
import 'package:mosa/screens/stats/widgets/operation_grid_item_widget.dart';
import 'package:mosa/utils/app_colors.dart';
import 'package:mosa/utils/app_icons.dart';
import 'package:mosa/widgets/stat_card.dart';

class StatsShellScreen extends StatelessWidget {
  const StatsShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Báo cáo', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.background,
        centerTitle: true,
        elevation: 2,
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(color: AppColors.secondaryBackground),
        child: SingleChildScrollView(
          child: Column(
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
                      AppColors.primary,
                      AppColors.fourth,
                      AppColors.third,
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
                      '15.000.222.111 đ',
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
              Row(
                children: [
                  Expanded(
                    child: OperationGridItemWidget(
                      iconPath: AppIcons.statisticIcon,
                      title: 'Phân tích chi tiêu',
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: OperationGridItemWidget(
                      iconPath: AppIcons.statisticIcon,
                      title: 'Phân tích chi tiêu',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: OperationGridItemWidget(
                      iconPath: AppIcons.statisticIcon,
                      title: 'Phân tích chi tiêu',
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: OperationGridItemWidget(
                      iconPath: AppIcons.statisticIcon,
                      title: 'Phân tích chi tiêu',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: OperationGridItemWidget(
                      iconPath: AppIcons.statisticIcon,
                      title: 'Phân tích chi tiêu',
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: OperationGridItemWidget(
                      iconPath: AppIcons.statisticIcon,
                      title: 'Phân tích chi tiêu',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: OperationGridItemWidget(
                      iconPath: AppIcons.statisticIcon,
                      title: 'Phân tích chi tiêu',
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: OperationGridItemWidget(
                      iconPath: AppIcons.statisticIcon,
                      title: 'Phân tích chi tiêu',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
