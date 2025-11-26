import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/providers/category_provider.dart';
import 'package:mosa/utils/app_colors.dart';
import 'package:mosa/utils/app_icons.dart';
import 'package:mosa/widgets/category_grid_view.dart';
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
      decoration: BoxDecoration(color: AppColors.background),
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: SearchBarWidget(
              onChange: (value) {
                log(value);
              },
              onClear: () => print('Clear text'),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hay dùng'),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(15, (index) {
                      return ItemWidget(
                        itemId: '1',
                        iconPath: AppIcons.statisticIcon,
                        name: 'Quỹ nhóm',
                        type: 'income',
                        iconType: 'material',
                      );
                    }),
                  ),
                ),
              ],
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
                  if (category.children == null || category.children == []) {
                    return ItemWidget(
                      itemId: category.id,
                      name: category.name,
                      type: category.type,
                      iconType: category.iconType,
                      iconPath: category.iconPath,
                      onTap: () {
                        ref.read(selectedCategoryProvider.notifier).selectCategory(category);
                        context.pop();
                      },
                    );
                  } else {
                    return CustomExpansionTile(
                      header: ItemWidget(
                        itemId: category.id,
                        name: category.name,
                        type: category.type,
                        iconType: category.iconType,
                        iconPath: category.iconPath,
                        onTap: () {
                          ref.read(selectedCategoryProvider.notifier).selectCategory(category);
                          context.pop();
                        },
                      ),
                      children: List.generate(category.children!.length, (index) {
                        final child = category.children![index];
                        log(child.toJson().toString());
                        return ItemWidget(
                          itemId: child.id,
                          name: child.name,
                          type: child.type,
                          iconType: child.iconType,
                          iconPath: child.iconPath,
                          onTap: () {
                            ref.read(selectedCategoryProvider.notifier).selectCategory(child);
                            context.pop();
                          },
                        );
                      }),
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
      // child: Column(
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   children: [
      //
      //     // CustomExpansionTile(
      //     //   title: Row(children: [Icon(Icons.card_giftcard_rounded), const SizedBox(width: 4), Text('Người yêu')]),
      //     //   children: [
      //     //     CategoryGridView(
      //     //       categories: [
      //     //         ItemWidget(itemId: '1', iconPath: AppIcons.statisticIcon, title: 'Ăn sáng'),
      //     //         ItemWidget(itemId: '2', iconPath: AppIcons.statisticIcon, title: 'Ăn trưa'),
      //     //         ItemWidget(itemId: '3', iconPath: AppIcons.statisticIcon, title: 'Ăn chiều'),
      //     //         ItemWidget(itemId: '4', iconPath: AppIcons.statisticIcon, title: 'Ăn tối'),
      //     //         ItemWidget(itemId: '5', iconPath: AppIcons.statisticIcon, title: 'Đồ uống'),
      //     //         ItemWidget(itemId: '6', iconPath: AppIcons.statisticIcon, title: 'Khác'),
      //     //       ],
      //     //     ),
      //     //   ],
      //     // ),
      //     // CustomExpansionTile(
      //     //   title: Row(
      //     //     children: [Image.asset(AppIcons.logoZalopay, width: 22), const SizedBox(width: 4), Text('Ăn uống')],
      //     //   ),
      //     //   children: [
      //     //     CategoryGridView(
      //     //       categories: [
      //     //         ItemWidget(itemId: '1', iconPath: AppIcons.statisticIcon, title: 'Ăn sáng'),
      //     //         ItemWidget(itemId: '2', iconPath: AppIcons.statisticIcon, title: 'Ăn trưa'),
      //     //         ItemWidget(itemId: '3', iconPath: AppIcons.statisticIcon, title: 'Ăn chiều'),
      //     //         ItemWidget(itemId: '4', iconPath: AppIcons.statisticIcon, title: 'Ăn tối'),
      //     //         ItemWidget(itemId: '5', iconPath: AppIcons.statisticIcon, title: 'Đồ uống'),
      //     //         ItemWidget(itemId: '6', iconPath: AppIcons.statisticIcon, title: 'Khác'),
      //     //       ],
      //     //     ),
      //     //   ],
      //     // ),
      //   ],
      // ),
    );
  }
}
