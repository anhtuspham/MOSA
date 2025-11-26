import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/models/category.dart';
import 'package:mosa/providers/category_provider.dart';

class ItemWidget extends ConsumerWidget {
  final String itemId;
  final String name;
  final String? type;
  final String? iconType;
  final String iconPath;
  final void Function()? onTap;

  const ItemWidget({
    super.key,
    required this.itemId,
    required this.name,
    this.type,
    this.iconType,
    required this.iconPath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Category(
            id: itemId,
            name: name,
            type: type ?? '',
            iconType: iconType ?? 'material',
            iconPath: iconPath,
          ).getIcon(),
          Text(
            name,
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
