import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/providers/category_provider.dart';
import 'package:mosa/utils/app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    final asyncCategories = ref.watch(categoryByTypeProvider(widget.categoryType));

    return Container(
      decoration: BoxDecoration(color: AppColors.secondaryBackground),
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: SearchBarWidget(
              onChange: (value) {
                log(value);
              },
              onClear: () => log('Clear text'),
            ),
          ),
          asyncCategories.when(
            data: (categories) {
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  if (category.children == null || category.children!.isEmpty) {
                    return Container(
                      color: AppColors.background,
                      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 3),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      child: ItemWidget(
                        category: category,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        onTap: () {
                          ref.read(selectedCategoryProvider.notifier).selectCategory(category);
                          context.pop();
                        },
                      ),
                    );
                  } else {
                    return CustomExpansionTile(
                      initialExpand: true,
                      header: ItemWidget(
                        category: category,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        onTap: () {
                          ref.read(selectedCategoryProvider.notifier).selectCategory(category);
                          context.pop();
                        },
                      ),
                      children: [
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: category.children!.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 10,
                            childAspectRatio: 1.4
                          ),
                          itemBuilder: (context, index) {
                            final child = category.children![index];
                            return ItemWidget(
                              category: child,
                              onTap: () {
                                ref.read(selectedCategoryProvider.notifier).selectCategory(child);
                                context.pop();
                              },
                            );
                          },
                        ),
                      ],
                    );
                  }
                },
              );
            },
            loading: () => Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(child: Text('Lỗi: $error')),
          ),
        ],
      ),
    );
  }
}
