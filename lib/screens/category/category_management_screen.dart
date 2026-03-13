import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/widgets/common_scaffold.dart';
import 'package:mosa/screens/category/widgets/category_management_tab_widget.dart';
import 'package:mosa/screens/category/widgets/category_form_bottom_sheet.dart';

class CategoryManagementScreen extends ConsumerStatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  ConsumerState<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends ConsumerState<CategoryManagementScreen> {
  int _currentIndex = 0;

  void _showAddCategorySheet() {
    final defaultType = switch (_currentIndex) {
      0 => 'income',
      1 => 'expense',
      2 => 'other',
      _ => 'income',
    };
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CategoryFormBottomSheet(
        initialType: defaultType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: const Text('Quản lý hạng mục'),
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back),
      ),
      appBarBackgroundColor: Theme.of(context).colorScheme.surface,
      tabs: const [
        Tab(child: Text('Thu nhập')),
        Tab(child: Text('Chi tiêu')),
        Tab(child: Text('Khác')),
      ],
      children: const [
        CategoryManagementTab(categoryType: 'income'),
        CategoryManagementTab(categoryType: 'expense'),
        CategoryManagementTab(categoryType: 'other'),
      ],
      onTabChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategorySheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}
