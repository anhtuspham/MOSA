import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/models/debt.dart';
import 'package:mosa/providers/debt_provider.dart';
import 'package:mosa/utils/app_colors.dart';
import 'package:mosa/widgets/common_scaffold.dart';
import 'package:mosa/widgets/debt/person_debt_item.dart';

class DebtSelectionScreen extends ConsumerWidget {
  final DebtType debtType; // lent for collection, borrowed for repayment

  const DebtSelectionScreen({super.key, required this.debtType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtSummaryByType = ref.watch(debtSummaryByTypeProvider(debtType));
    final isLent = debtType == DebtType.lent;

    return CommonScaffold(
      title: Text(isLent ? 'Chọn khoản nợ cần thu' : 'Chọn khoản nợ cần trả'),
      leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back)),
      appBarBackgroundColor: AppColors.background,
      body: ListView.builder(
        itemCount: debtSummaryByType.values.length,
        itemBuilder: (context, index) {
          final debt = debtSummaryByType.entries.elementAt(index);
          return PersonDebtItem(
            isLent: isLent,
            personId: debt.key,
            onTap: () => context.pop<Map<String, dynamic>>({'personId': debt.key, 'debtAmount': debt.value}),
          );
        },
      ),
    );
  }
}
