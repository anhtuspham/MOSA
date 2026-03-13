import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mosa/models/category.dart';
import 'package:mosa/providers/category_provider.dart';
import 'package:mosa/utils/toast.dart';
import 'package:mosa/screens/category/widgets/category_form_bottom_sheet.dart';

class CategoryManagementTab extends ConsumerWidget {
  final String categoryType;

  const CategoryManagementTab({super.key, required this.categoryType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCategories = ref.watch(flattenedCategoryProvider);

    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainer),
      child: asyncCategories.when(
        data: (allCategories) {
          final categories = allCategories.where((c) {
            if (categoryType == 'other') {
              return c.type != 'income' && c.type != 'expense';
            }
            return c.type == categoryType;
          }).toList();

          if (categories.isEmpty) {
            return const Center(child: Text('Không có hạng mục nào'));
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: categories.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final category = categories[index];
              return Container(
                color: Theme.of(context).colorScheme.surface,
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: category.getIcon(),
                  ),
                  title: Text(category.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => CategoryFormBottomSheet(
                              category: category,
                              initialType: categoryType,
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _showDeleteDialog(context, ref, category);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Lỗi: $error')),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa hạng mục "${category.name}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(categoriesProvider.notifier).deleteCategory(category.id);
                showResultToast('Đã xóa hạng mục');
              } catch (e) {
                showResultToast(e.toString(), isError: true);
              }
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
