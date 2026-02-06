import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/providers/category_provider.dart';
import 'package:mosa/router/app_routes.dart';
import 'package:mosa/utils/transaction_constants.dart';
import 'package:mosa/widgets/card_section.dart';
import 'package:mosa/widgets/custom_list_tile.dart';

/// Widget for category selection section
class CategorySelectorSection extends ConsumerWidget {
  final VoidCallback? onCategorySelected;

  const CategorySelectorSection({
    super.key,
    this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    
    return CardSection(
      child: Column(
        children: [
          CustomListTile(
            leading: selectedCategory != null 
                ? selectedCategory.getIcon() 
                : const Icon(Icons.add_circle_rounded),
            title: Text(
              selectedCategory != null 
                  ? selectedCategory.name 
                  : TransactionConstants.selectCategory
            ),
            trailing: Row(
              children: [
                Text(TransactionConstants.allCategories),
                const SizedBox(width: 12),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () async {
              await context.push(AppRoutes.categoryList);
              onCategorySelected?.call();
            },
          ),
        ],
      ),
    );
  }
}
