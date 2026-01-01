import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;

  /// income / expense / lend / borrow
  final String type;

  /// custom / material
  final String iconType; // custom / material
  final String iconPath;
  final String? color;
  final String? parentId;
  final List<Category>? children;

  Category({
    required this.id,
    required this.name,
    required this.type,
    required this.iconType,
    required this.iconPath,
    this.color,
    this.parentId,
    this.children = const [],
  });

  bool? get isParent => children?.isNotEmpty;

  bool get isChild => parentId != null;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      iconType: json['iconType'] ?? 'custom',
      iconPath: json['iconPath'] as String,
      color: json['color'] as String?,
      parentId: json["parentId"] != null ? json['parentId'] : null,
      children:
          json['children'] != null
              ? (json['children'] as List<dynamic>)
                  .map((e) => Category.fromJson(e))
                  .toList()
              : [],
    );
  }

  factory Category.empty() => Category(id: 'unknown', name: 'unknown', type: 'unknown', iconType: 'custom', iconPath: 'assets/icons/default.png');

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'iconType': iconType,
      'iconPath': iconPath,
      'color': color,
      'parentId': parentId,
      'children': children?.map((e) => e.toJson()).toList(),
    };
  }

  Widget getIcon({double size = 24}) {
    final color =
        this.color != null
            ? Color(int.parse('0xFF${this.color!.substring(1)}'))
            : Colors.grey;

    if (iconType == 'custom') {
      return Image.asset(iconPath, width: size, height: size);
    } else {
      return Icon(_getMaterialIcon(iconPath), color: color, size: size);
    }
  }

  static Category? findByName(List<Category> categories, String name) {
    for (final category in categories) {
      if (category.name.toLowerCase() == name.toLowerCase()) {
        return category;
      }
      // Tìm trong children nếu có
      if (category.children?.isNotEmpty == true) {
        final found = findByName(category.children!, name);
        if (found != null) return found;
      }
    }
    return null;
  }

  static Category? findByType(List<Category> categories, String type, {String? name}) {
    for (final category in categories) {
      if (category.type == type && (name == null || category.name.toLowerCase() == name.toLowerCase())) {
        return category;
      }
      // Tìm trong children nếu có
      if (category.children?.isNotEmpty == true) {
        final found = findByType(category.children!, type, name: name);
        if (found != null) return found;
      }
    }
    return null;
  }

  static IconData _getMaterialIcon(String iconName) {
    const iconMap = {
      // Income
      'attach_money': Icons.attach_money,
      'more_horiz': Icons.more_horiz,
      'card_giftcard': Icons.card_giftcard,
      'monetization_on': Icons.monetization_on,
      'trending_up': Icons.trending_up,

      // Expense - Food
      'restaurant': Icons.restaurant,
      'breakfast_dining': Icons.breakfast_dining,
      'lunch_dining': Icons.lunch_dining,
      'dinner_dining': Icons.dinner_dining,

      // Expense - Shopping
      'shopping_cart': Icons.shopping_cart,
      'checkroom': Icons.checkroom,
      'devices': Icons.devices,
      'shopping_bag': Icons.shopping_bag,

      // Expense - Entertainment
      'movie': Icons.movie,

      // Expense - Transport
      'directions_car': Icons.directions_car,
      'local_taxi': Icons.local_taxi,
      'directions_bus': Icons.directions_bus,
      'two_wheeler': Icons.two_wheeler,

      // Expense - Other
      'receipt': Icons.receipt,
      'health_and_safety': Icons.health_and_safety,
      'school': Icons.school,
      'flight': Icons.flight,
      'home': Icons.home,
      'local_cafe': Icons.local_cafe,

      // Lend / Borrow
      'handshake': Icons.handshake,
      'gavel': Icons.gavel,
      'check_circle': Icons.check_circle,
      'paid': Icons.paid,

      // transfer
      'autorenew': Icons.autorenew,
    };

    return iconMap[iconName] ?? Icons.help;
  }
}
