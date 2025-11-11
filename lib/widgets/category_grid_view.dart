import 'package:flutter/material.dart';
import 'package:mosa/widgets/item_widget.dart';

class CategoryGridView extends StatelessWidget {
  final List<ItemWidget> categories;
  final Function(ItemWidget) onTap;
  const CategoryGridView({super.key, required this.categories, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return ItemWidget(iconPath: category.iconPath, title: category.title, onTap: () => onTap(category));
      },
    );
  }
}
