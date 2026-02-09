import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mosa/models/enums.dart';
import 'package:mosa/providers/category_provider.dart';
import 'package:mosa/providers/transaction_provider.dart';
import 'package:mosa/utils/transaction_constants.dart';
import 'package:mosa/utils/utils.dart';

/// Dropdown widget for selecting transaction type
class TransactionTypeDropdown extends ConsumerWidget {
  final Function(TransactionType)? onTypeChanged;

  const TransactionTypeDropdown({super.key, this.onTypeChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTransactionType = ref.watch(currentTransactionByTypeProvider) ?? TransactionType.expense;

    return DropdownButtonFormField<TransactionType>(
      decoration: const InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.never,
        floatingLabelAlignment: FloatingLabelAlignment.center,
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        border: OutlineInputBorder(borderSide: BorderSide.none),
      ),
      isExpanded: true,
      alignment: Alignment.center,
      initialValue: selectedTransactionType,
      items: [
        DropdownMenuItem(value: TransactionType.expense, child: Text(TransactionConstants.expense)),
        DropdownMenuItem(value: TransactionType.income, child: Text(TransactionConstants.income)),
        DropdownMenuItem(value: TransactionType.lend, child: Text(TransactionConstants.lend)),
        DropdownMenuItem(value: TransactionType.borrowing, child: Text(TransactionConstants.borrowing)),
        DropdownMenuItem(value: TransactionType.transfer, child: Text(TransactionConstants.transfer)),
        DropdownMenuItem(value: TransactionType.adjustBalance, child: Text(TransactionConstants.adjustBalance)),
      ],
      onChanged: (value) async {
        if (value != null) {
          ref.read(currentTransactionByTypeProvider.notifier).state = value;

          final categoryName = getCategoryNameForTransactionType(value);
          onTypeChanged?.call(value);

          if (categoryName != null) {
            try {
              final category = await ref.read(categoryByNameProvider(categoryName).future);
              log('category: ${category?.name}');
              ref.read(selectedCategoryProvider.notifier).selectCategory(category);
            } catch (e) {
              ref.read(selectedCategoryProvider.notifier).selectCategory(null);
            }
          } else {
            ref.read(selectedCategoryProvider.notifier).selectCategory(null);
          }
        }
      },
    );
  }
}
