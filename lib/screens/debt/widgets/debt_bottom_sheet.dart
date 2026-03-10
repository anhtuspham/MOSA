import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/models/debt.dart';
import 'package:mosa/models/enums.dart';
import 'package:mosa/providers/category_provider.dart';
import 'package:mosa/providers/debt_provider.dart';
import 'package:mosa/providers/person_provider.dart';
import 'package:mosa/providers/transaction_prefill_data_provider.dart';
import 'package:mosa/router/app_routes.dart';
import 'package:mosa/utils/helpers.dart';
import 'package:mosa/widgets/custom_list_tile.dart';

class DebtBottomSheet extends ConsumerWidget {
  const DebtBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We expect the selected debt to be provided before opening this sheet
    final selectedDebt = ref.watch(selectedDebtProvider);
    if (selectedDebt == null) return const SizedBox.shrink();

    final isLent = selectedDebt.type == DebtType.lent;
    final title = isLent ? 'Thu nợ' : 'Trả nợ';
    final remainingAmount = selectedDebt.amount - selectedDebt.paidAmount;

    return Container(
      padding: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          CustomListTile(
            leading: const Icon(Icons.swap_horiz, size: 20),
            title: Text(
              Helpers.formatCurrency(remainingAmount),
              style: const TextStyle(fontSize: 16),
            ),
            onTap: () async {
              context.pop();
              _navigateToTransaction(context, ref, selectedDebt, isLent, remainingAmount);
            },
            backgroundColor: Colors.transparent,
          ),
          CustomListTile(
            leading: const Icon(Icons.currency_exchange, size: 20),
            title: const Text('Số tiền khác', style: TextStyle(fontSize: 16)),
            onTap: () async {
              context.pop();
              _navigateToTransaction(context, ref, selectedDebt, isLent, 0);
            },
            backgroundColor: Colors.transparent,
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToTransaction(
    BuildContext context,
    WidgetRef ref,
    Debt debt,
    bool isLent,
    double prefillAmount,
  ) async {
    final debtCollectionCategory = await ref.read(categoryByNameProvider('Thu nợ').future);
    final debtRepaymentCategory = await ref.read(categoryByNameProvider('Trả nợ').future);
    final person = ref.read(personByIdProvider(debt.personId));
    
    final category = isLent ? debtCollectionCategory : debtRepaymentCategory;
    final transactionType = isLent ? TransactionType.income : TransactionType.expense;
    
    ref.read(transactionPrefillDataProvider.notifier).state = TransactionPrefill(
      person: person,
      amount: prefillAmount,
      type: transactionType,
      category: category,
      debtId: debt.id, // Set the debtId for automated linking!
    );
    
    // Future.delayed to let bottom sheet close smoothly
    await Future.delayed(const Duration(milliseconds: 150));
    if (context.mounted) {
      context.go(AppRoutes.addTransaction);
    }
  }
}
