import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/providers/budget_provider.dart';
import 'package:mosa/screens/budget/widgets/budget_progress_card.dart';
import 'package:mosa/config/app_colors.dart';
import 'package:mosa/widgets/common_scaffold.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(budgetProvider.notifier).refreshBudgets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final budgetProgressAsync = ref.watch(budgetProgressProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return CommonScaffold.single(
      title: const Text('Ngân sách', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      appBarBackgroundColor: colorScheme.onPrimaryFixedVariant,
      elevation: false,
      leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
      actions: [
        IconButton(
          icon: Icon(Icons.add_circle_outline, color: Colors.white),
          onPressed: () => context.pushNamed('add-budget'),
        ),
      ],
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: budgetProgressAsync.when(
          data: (progressList) {
            if (progressList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.account_balance_wallet_outlined, size: 64, color: AppColors.textHint),
                    const SizedBox(height: 16),
                    Text(
                      'Bạn chưa tạo ngân sách nào cho tháng này.',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonPrimary),
                      onPressed: () => context.pushNamed('add-budget'),
                      child: const Text('Tạo Ngân Sách', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await ref.read(budgetProvider.notifier).refreshBudgets();
              },
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 80),
                itemCount: progressList.length,
                itemBuilder: (context, index) {
                  return BudgetProgressCard(progress: progressList[index]);
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Đã có lỗi xảy ra: $err')),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => context.pushNamed('add-budget'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
