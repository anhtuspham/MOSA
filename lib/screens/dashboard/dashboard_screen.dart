import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mosa/providers/dashboard_provider.dart';
import 'package:mosa/providers/debt_provider.dart';
import 'package:mosa/providers/transaction_provider.dart';
import 'package:mosa/providers/wallet_provider.dart';
import 'package:mosa/screens/dashboard/widgets/asset_debt_summary_card.dart';
import 'package:mosa/screens/dashboard/widgets/cash_flow_bar_chart.dart';
import 'package:mosa/screens/dashboard/widgets/expense_pie_chart.dart';
import 'package:mosa/config/app_colors.dart';
import 'package:mosa/widgets/common_scaffold.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    await Future.wait([
      ref.read(walletProvider.notifier).refreshWallet(),
      ref.read(transactionProvider.notifier).refreshTransactions(),
      ref.read(debtProvider.notifier).refreshListDebt(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final dashboardData = ref.watch(dashboardProvider);

    return CommonScaffold.single(
      title: const Text('Tổng quan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      appBarBackgroundColor: AppColors.primary,
      elevation: false,
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    AssetDebtSummaryCard(data: dashboardData),
                    const SizedBox(height: 16),
                    const CashFlowBarChart(),
                    const SizedBox(height: 16),
                    const ExpensePieChart(),
                    const SizedBox(height: 48), // Padding at bottom
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
