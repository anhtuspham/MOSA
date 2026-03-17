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
  final IconData? icon;
  final void Function()? onTap;
  final CrossAxisAlignment? crossAxisAlignment;

  const ItemWidget({
    super.key,
    this.category,
    this.itemId,
    this.name,
    this.type,
    this.icon,
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
              color: Colors.white, // Nền trắng đảm bảo logo luôn nổi bật bất kể theme
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5), width: 1),
            ),
            child:
                icon != null
                    ? Icon(icon, color: Colors.black)
                    : category?.getIcon() ?? Image.asset(iconPath ?? 'assets/icons/default.png', width: 24, height: 24),
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
