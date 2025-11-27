import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mosa/models/category.dart';

class ItemWidget extends ConsumerWidget {
  final Category? category;
  final String? itemId;
  final String? name;
  final String? type;
  final String? iconType;
  final String? iconPath;
  final void Function()? onTap;
  final CrossAxisAlignment? crossAxisAlignment;

  const ItemWidget({
    super.key,
    this.category,
    this.itemId,
    this.name,
    this.type,
    this.iconType,
    this.iconPath,
    this.crossAxisAlignment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child:
                (category ??
                        Category(
                          id: itemId ?? '',
                          name: name ?? '',
                          type: type ?? '',
                          iconType: iconType ?? 'material',
                          iconPath: iconPath ?? '',
                        ))
                    .getIcon(),
          ),
          const SizedBox(height: 4),
          Text(
            category?.name ?? name ?? '',
            style: TextStyle(fontSize: 11),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
