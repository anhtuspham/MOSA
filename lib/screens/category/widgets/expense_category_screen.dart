import 'package:flutter/material.dart';
import 'package:mosa/utils/app_colors.dart';
import 'package:mosa/utils/app_icons.dart';
import 'package:mosa/widgets/category_grid_view.dart';
import 'package:mosa/widgets/custom_expansion_tile.dart';
import 'package:mosa/widgets/item_widget.dart';
import 'package:mosa/widgets/search_bar_widget.dart';

class ExpenseCategoryScreen extends StatefulWidget {
  const ExpenseCategoryScreen({super.key});

  @override
  State<ExpenseCategoryScreen> createState() => _ExpenseCategoryScreenState();
}

class _ExpenseCategoryScreenState extends State<ExpenseCategoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.background),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: SearchBarWidget(
                onChange: (value) {
                  print(value);
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
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(15, (index) {
                        return ItemWidget(
                          iconPath: AppIcons.statisticIcon,
                          title: 'Quỹ nhóm',
                          onTap: () => print('onTap'),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            CustomExpansionTile(
              title: Row(children: [Icon(Icons.card_giftcard_rounded), const SizedBox(width: 4), Text('Người yêu')]),
              children: [
                CategoryGridView(
                  categories: [
                    ItemWidget(iconPath: AppIcons.statisticIcon, title: 'Quỹ nhóm', onTap: () => print('onTap')),
                    ItemWidget(iconPath: AppIcons.statisticIcon, title: 'Quỹ nhóm', onTap: () => print('onTap')),
                    ItemWidget(iconPath: AppIcons.statisticIcon, title: 'Quỹ nhóm', onTap: () => print('onTap')),
                    ItemWidget(iconPath: AppIcons.statisticIcon, title: 'Quỹ nhóm', onTap: () => print('onTap')),
                    ItemWidget(iconPath: AppIcons.statisticIcon, title: 'Quỹ nhóm', onTap: () => print('onTap')),
                    ItemWidget(iconPath: AppIcons.statisticIcon, title: 'Quỹ nhóm', onTap: () => print('onTap')),
                  ],
                  onTap: (itemWidget) => print(itemWidget.iconPath),
                ),
              ],
            ),
            CustomExpansionTile(
              title: Row(
                children: [Image.asset(AppIcons.logoZalopay, width: 22), const SizedBox(width: 4), Text('Ăn uống')],
              ),
              children: [
                CategoryGridView(
                  categories: [
                    ItemWidget(iconPath: AppIcons.statisticIcon, title: 'Quỹ nhóm', onTap: () => print('onTap')),
                    ItemWidget(iconPath: AppIcons.statisticIcon, title: 'Quỹ nhóm', onTap: () => print('onTap')),
                    ItemWidget(iconPath: AppIcons.statisticIcon, title: 'Quỹ nhóm', onTap: () => print('onTap')),
                    ItemWidget(iconPath: AppIcons.statisticIcon, title: 'Quỹ nhóm', onTap: () => print('onTap')),
                    ItemWidget(iconPath: AppIcons.statisticIcon, title: 'Quỹ nhóm', onTap: () => print('onTap')),
                    ItemWidget(iconPath: AppIcons.statisticIcon, title: 'Quỹ nhóm', onTap: () => print('onTap')),
                  ],
                  onTap: (itemWidget) => print(itemWidget.iconPath),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
