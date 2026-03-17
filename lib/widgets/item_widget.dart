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
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3), width: 1),
            ),
            child:
                icon != null
                    ? Icon(icon, color: colorScheme.primary, size: 28)
                    : category?.getIcon() ??
                        Image.asset(
                          iconPath ?? 'assets/icons/default.png',
                          width: 28,
                          height: 28,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.category_outlined, color: colorScheme.primary);
                          },
                        ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              category?.name ?? name ?? '',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colorScheme.onSurface, height: 1.2),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
