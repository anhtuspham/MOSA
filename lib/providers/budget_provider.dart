import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mosa/models/budget.dart';
import 'package:mosa/models/enums.dart';
import 'package:mosa/providers/transaction_provider.dart';
import 'package:mosa/services/database_service.dart';
// Service provider
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

// Current filter provider for budget
class BudgetDateFilterNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void updateDate(DateTime date) {
    state = date;
  }
}

// Current filter provider for budget
final budgetDateFilterProvider = NotifierProvider<BudgetDateFilterNotifier, DateTime>(
  BudgetDateFilterNotifier.new,
);

class BudgetNotifier extends AsyncNotifier<List<Budget>> {
  DatabaseService get _db => ref.read(databaseServiceProvider);

  @override
  Future<List<Budget>> build() async {
    final date = ref.watch(budgetDateFilterProvider);
    return await _db.getBudgetsByMonth(date.month, date.year);
  }

  Future<void> refreshBudgets() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final date = ref.read(budgetDateFilterProvider);
      return await _db.getBudgetsByMonth(date.month, date.year);
    });
  }

  Future<void> upsertBudget(Budget budget) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _db.upsertBudget(budget);
      final date = ref.read(budgetDateFilterProvider);
      return await _db.getBudgetsByMonth(date.month, date.year);
    });
  }

  Future<void> deleteBudget(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _db.deleteBudget(id);
      final date = ref.read(budgetDateFilterProvider);
      return await _db.getBudgetsByMonth(date.month, date.year);
    });
  }
}

final budgetProvider = AsyncNotifierProvider<BudgetNotifier, List<Budget>>(
  BudgetNotifier.new,
);

class BudgetProgress {
  final Budget budget;
  final double spentAmount;

  BudgetProgress({required this.budget, required this.spentAmount});

  double get percentage => budget.amount > 0 ? (spentAmount / budget.amount) : 0;
  bool get isOverBudget => spentAmount > budget.amount;
  double get remaining => budget.amount - spentAmount;
}

final budgetProgressProvider = Provider.autoDispose<AsyncValue<List<BudgetProgress>>>((ref) {
  final budgetsAsync = ref.watch(budgetProvider);
  final transactionsAsync = ref.watch(transactionProvider);
  final currentDate = ref.watch(budgetDateFilterProvider);

  if (budgetsAsync.isLoading || transactionsAsync.isLoading) {
    return const AsyncLoading();
  }

  if (budgetsAsync.hasError) {
    return AsyncError(budgetsAsync.error!, budgetsAsync.stackTrace!);
  }

  final budgets = budgetsAsync.value ?? [];
  final transactions = transactionsAsync.value ?? [];

  // Filter expenses for current month
  final currentMonthExpenses = transactions.where((t) {
    if (t.type != TransactionType.expense) return false;
    final tDate = t.date;
    return tDate.month == currentDate.month && tDate.year == currentDate.year;
  }).toList();

  final List<BudgetProgress> progressList = budgets.map((budget) {
    final double spent = currentMonthExpenses
        .where((t) => t.categoryId == budget.categoryId)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    return BudgetProgress(budget: budget, spentAmount: spent);
  }).toList();

  return AsyncData(progressList);
});
