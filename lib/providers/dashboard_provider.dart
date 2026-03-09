import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mosa/models/debt.dart';
import 'package:mosa/models/enums.dart';
import 'package:mosa/providers/debt_provider.dart';
import 'package:mosa/providers/transaction_provider.dart';
import 'package:mosa/providers/wallet_provider.dart';

/// Provider tổng hợp dữ liệu cho Dashboard
final dashboardProvider = Provider.autoDispose<DashboardData>((ref) {
  final totalAssets = ref.watch(totalBalanceWalletProvider);

  final lentInfo = ref.watch(totalDebtByTypeProvider(DebtType.lent));
  final borrowedInfo = ref.watch(totalDebtByTypeProvider(DebtType.borrowed));

  final totalLent = lentInfo.totalDebtRemaining;
  final totalDebt = borrowedInfo.totalDebtRemaining;

  final netWorth = totalAssets + totalLent - totalDebt;

  final income = ref.watch(totalIncomeProvider);
  final expense = ref.watch(totalExpenseProvider);

  return DashboardData(
    totalAssets: totalAssets,
    totalLent: totalLent,
    totalDebt: totalDebt,
    netWorth: netWorth,
    totalIncome: income,
    totalExpense: expense,
  );
});

class DashboardData {
  final double totalAssets;
  final double totalLent;
  final double totalDebt;
  final double netWorth;
  final double totalIncome;
  final double totalExpense;

  DashboardData({
    required this.totalAssets,
    required this.totalLent,
    required this.totalDebt,
    required this.netWorth,
    required this.totalIncome,
    required this.totalExpense,
  });
}

/// Helper provider for Cash Flow Bar Chart
final cashFlowChartProvider = Provider.autoDispose<List<CashFlowData>>((ref) {
  // Simple implementation capturing global totals for now
  // For a real bar chart this could be split by day/week using transactions
  final data = ref.watch(dashboardProvider);
  return [
    CashFlowData(label: 'Thu', amount: data.totalIncome, isIncome: true),
    CashFlowData(label: 'Chi', amount: data.totalExpense, isIncome: false),
  ];
});

class CashFlowData {
  final String label;
  final double amount;
  final bool isIncome;

  CashFlowData({
    required this.label,
    required this.amount,
    required this.isIncome,
  });
}
