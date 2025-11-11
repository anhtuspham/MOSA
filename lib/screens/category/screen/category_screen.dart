import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/screens/category/widgets/expense_category_screen.dart';
import 'package:mosa/utils/app_colors.dart';
import 'package:mosa/widgets/tabBar_scaffold.dart';

/// Screen to select transaction category with expense, income, and loan tabs
class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  Widget build(BuildContext context) {
    return TabBarScaffold(
      title: const Text('Chọn hạng mục'),
      leading: IconButton(
        onPressed: () {
          context.pop();
        },
        icon: const Icon(Icons.arrow_back),
      ),
      actions: const [Icon(Icons.edit_note_sharp), SizedBox(width: 12), Icon(Icons.filter_list)],
      appBarBackgroundColor: AppColors.background,
      tabs: const [Tab(child: Text('Chi tiền')), Tab(child: Text('Thu tiền')), Tab(child: Text('Vay nợ'))],
      children: [ExpenseCategoryScreen(), _buildCategoryTab('Thu tiền'), _buildCategoryTab('Vay nợ')],
    );
  }

  /// Build category content for each tab
  Widget _buildCategoryTab(String tabTitle) {
    return Center(child: Text(tabTitle));
  }
}
