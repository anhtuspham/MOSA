import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/models/enums.dart';
import 'package:mosa/providers/transaction_provider.dart';
import 'package:mosa/screens/category/widgets/category_tab_widget.dart';
import 'package:mosa/utils/app_colors.dart';
import 'package:mosa/widgets/tab_bar_scaffold.dart';

/// Screen to select transaction category with expense, income, and loan tabs
class CategoryScreen extends ConsumerStatefulWidget {
  const CategoryScreen({super.key});

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  int initialIndexValue() {
    final currentCategoryType = ref.watch(currentTransactionByTypeProvider);
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
    return CommonScaffold(
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
      appBarBackgroundColor: AppColors.background,
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
