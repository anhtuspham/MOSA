import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/models/category.dart';
import 'package:mosa/providers/category_provider.dart';

class ItemWidget extends ConsumerWidget {
  final String iconPath;
  final String title;
  final String itemId;
  const ItemWidget({super.key, required this.iconPath, required this.title, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref
            .read(categoryNotifier.notifier)
            .selectCategory(Category(categoryId: itemId, iconPath: iconPath, categoryName: title));
        context.pop();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(iconPath, width: 25),
          Text(
            title,
            style: TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
