import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/providers/category_provider.dart';
import 'package:mosa/providers/person_provider.dart';
import 'package:mosa/providers/transaction_prefill_data_provider.dart';
import 'package:mosa/router/app_routes.dart';

import 'package:mosa/widgets/custom_expansion_tile.dart';
import 'package:mosa/widgets/item_widget.dart';
import 'package:mosa/widgets/search_bar_widget.dart';

class CategoryTab extends ConsumerStatefulWidget {
  final String categoryType;

  const CategoryTab({super.key, required this.categoryType});

  @override
  ConsumerState<CategoryTab> createState() => _CategoryTabState();
}

class _CategoryTabState extends ConsumerState<CategoryTab> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Handle category selection with special logic for debt categories
  Future<void> _handleCategorySelection(BuildContext context, category) async {
    // Check if this is a debt-related category
    final categoryId = category.id;
    final categoryName = category.name?.toLowerCase() ?? '';

    // Select category
    ref.read(selectedCategoryProvider.notifier).selectCategory(category);

    // Get transaction type from category
    final transactionType = ref.read(autoTransactionTypeProvider);

    if (categoryId == 'lend_payback' || categoryName == 'trả nợ') {
      // Repayment - show borrowed debts
      final result = await context.push('${AppRoutes.debtSelection}?type=borrowed');

      if (result != null && result is Map) {
        final personId = result['personId'];
        final debtAmount = result['debtAmount'];

        final person = ref.watch(personByIdProvider(personId));
        // User selected a debt
        ref.read(transactionPrefillDataProvider.notifier).state = TransactionPrefill(
          amount: debtAmount,
          person: person,
          category: category,
          type: transactionType,
        );
        if (context.mounted) context.pop(category);
      }
    } else if (categoryId == 'lend_collect' || categoryName == 'thu nợ') {
      // Debt collection - show lent debts
      final result = await context.push('${AppRoutes.debtSelection}?type=lent');

      if (result != null && result is Map<String, dynamic>) {
        final personId = result['personId'];
        final debtAmount = result['debtAmount'];

        final person = ref.watch(personByIdProvider(personId));
        // User selected a debt
        ref.read(transactionPrefillDataProvider.notifier).state = TransactionPrefill(
          amount: debtAmount,
          person: person,
          category: category,
          type: transactionType,
        );
        if (context.mounted) context.pop(category);
      }
    } else {
      // Regular category - normal flow
      ref.read(transactionPrefillDataProvider.notifier).state = TransactionPrefill(
        category: category,
        type: transactionType,
      );
      context.pop(category);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncCategories = ref.watch(categoryByTypeProvider(widget.categoryType));

    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainer),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: SearchBarWidget(
              onChange: (value) {
                log(value, name: 'CategoryTab');
              },
              onClear: () => log('Clear text', name: 'CategoryTab'),
            ),
          ),
          Expanded(
            child: asyncCategories.when(
              data: (categories) {
                if (categories.isEmpty) {
                  return const Center(child: Text('Không có danh mục nào'));
                }
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    // Nếu không có con, hiển thị dạng item đơn giản
                    if (category.children?.isEmpty ?? true) {
                      return Container(
                        color: Theme.of(context).colorScheme.surface,
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        child: ItemWidget(
                          category: category,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          onTap: () => _handleCategorySelection(context, category),
                        ),
                      );
                    } else {
                      // Nếu có con, hiển thị dạng ExpansionTile
                      return CustomExpansionTile(
                        initialExpand: true,
                        header: ItemWidget(
                          category: category,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          onTap: () => _handleCategorySelection(context, category),
                        ),
                        children: [
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: category.children!.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 10,
                              childAspectRatio: 1.1,
                            ),
                            itemBuilder: (context, index) {
                              final child = category.children![index];
                              return ItemWidget(category: child, onTap: () => _handleCategorySelection(context, child));
                            },
                          ),
                        ],
                      );
                    }
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) {
                log('Lỗi tải danh mục: $error', name: 'CategoryTab', stackTrace: stackTrace);
                return Center(child: Text('Lỗi: $error'));
              },
            ),
          ),
        ],
      ),
    );
  }
}
