import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/models/enums.dart';
import 'package:mosa/providers/transaction_provider.dart';
import 'package:mosa/screens/category/widgets/category_tab_widget.dart';

import 'package:mosa/widgets/common_scaffold.dart';

/// Screen to select transaction category with expense, income, and loan tabs
class CategoryScreen extends ConsumerStatefulWidget {
  const CategoryScreen({super.key});

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  int initialIndexValue() {
    final currentCategoryType = ref.watch(activeTransactionTypeProvider);
    switch (currentCategoryType) {
      case TransactionType.expense:
        return 0;
      case TransactionType.income:
        return 1;
      case TransactionType.lend:
      case TransactionType.borrowing:
        return 2;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold.tabbed(
      title: const Text('Chọn hạng mục'),
      leading: IconButton(
        onPressed: () {
          context.pop();
        },
        icon: const Icon(Icons.arrow_back),
      ),
      initialIndex: initialIndexValue(),
      actions: const [
        Icon(Icons.edit_note_sharp),
        SizedBox(width: 12),
        Icon(Icons.filter_list),
      ],
      onTabChanged: (index) {
        final type = switch (index) {
          0 => TransactionType.expense,
          1 => TransactionType.income,
          2 => TransactionType.lend,
          _ => TransactionType.expense,
        };
        ref.read(activeTransactionTypeProvider.notifier).state = type;
      },
      appBarBackgroundColor: Theme.of(context).colorScheme.surface,
      tabs: const [
        Tab(child: Text('Chi tiền')),
        Tab(child: Text('Thu tiền')),
        Tab(child: Text('Vay nợ')),
      ],
      children: [
        CategoryTab(categoryType: 'expense'),
        CategoryTab(categoryType: 'income'),
        CategoryTab(categoryType: 'lend'),
      ],
    );
  }
}
