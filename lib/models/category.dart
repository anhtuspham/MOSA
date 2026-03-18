import 'dart:io';

import 'package:flutter/material.dart';

/// Model lưu trữ thông tin danh mục giao dịch
class Category {
  /// Mã định danh duy nhất (ví dụ: 'food', 'salary')
  final String id;

  /// Tên danh mục (ví dụ: 'Ăn uống', 'Lương')
  final String name;

  /// Loại giao dịch (expense, income, lend, borrowing, repayment, debtCollection)
  final String type;

  /// Loại icon ('custom' cho ảnh asset hoặc 'material' cho Material Icons)
  final String iconType;

  /// Đường dẫn (ví dụ: 'assets/icons/food.png') hoặc tên icon (ví dụ: 'attach_money')
  final String iconPath;

  /// Mã màu hex (ví dụ: '#FF5733')
  final String? color;

  /// ID của danh mục cha nếu là danh mục con
  final String? parentId;

  /// Danh sách các danh mục con
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

  /// Kiểm tra xem có phải là danh mục cha không
  bool? get isParent => children?.isNotEmpty;

  /// Kiểm tra xem có phải là danh mục con không
  bool get isChild => parentId != null;

  /// Tạo Category từ JSON (dùng cho seeding từ file assets)
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String? ?? 'unknown',
      name: json['name'] as String? ?? 'Chưa xác định',
      type: json['type'] as String? ?? 'expense',
      iconType: json['iconType'] as String? ?? 'custom',
      iconPath: json['iconPath'] as String? ?? 'assets/icons/default.png',
      color: json['color'] as String?,
      parentId: json['parentId'] as String?,
      children:
          json['children'] != null
              ? (json['children'] as List<dynamic>)
                  .map((e) => Category.fromJson(e))
                  .toList()
              : [],
    );
  }

  /// Tạo Category rỗng dùng làm fallback
  factory Category.empty() => Category(
    id: 'unknown',
    name: 'Chưa xác định',
    type: 'unknown',
    iconType: 'custom',
    iconPath: 'assets/icons/default.png',
  );

  /// Chuyển Category sang JSON
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

  /// Chuyển Category sang Map để lưu vào database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'iconType': iconType,
      'iconPath': iconPath,
      'color': color,
      'parentId': parentId,
      // children không được lưu trực tiếp vào bảng categories mà thông qua quan hệ database
    };
  }

  /// Tạo Category từ Map (database) với cơ chế fallback an toàn
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String? ?? 'unknown',
      name: map['name'] as String? ?? 'Chưa xác định',
      type: map['type'] as String? ?? 'expense',
      iconType: map['iconType'] as String? ?? 'custom',
      iconPath: map['iconPath'] as String? ?? 'assets/icons/default.png',
      color: map['color'] as String?,
      parentId: map['parentId'] as String?,
      children: [], // Khởi tạo danh sách con trống, sẽ được gán lại khi dựng cây
    );
  }

  /// Tạo bản sao của Category với một số trường thay đổi
  Category copyWith({
    String? id,
    String? name,
    String? type,
    String? iconType,
    String? iconPath,
    String? color,
    String? parentId,
    List<Category>? children,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      iconType: iconType ?? this.iconType,
      iconPath: iconPath ?? this.iconPath,
      color: color ?? this.color,
      parentId: parentId ?? this.parentId,
      children: children ?? this.children,
    );
  }

  /// Lấy icon của danh mục
  Widget getIcon({double size = 24, Color? color}) {
    final iconColor =
        color ??
        (this.color != null
            ? Color(int.parse('0xFF${this.color!.substring(1)}'))
            : Colors.grey);

    if (iconType == 'custom') {
      return Image.asset(iconPath, width: size, height: size, color: color);
    } else if (iconType == 'local_file') {
      return Image.file(
        File(iconPath),
        width: size,
        height: size,
        fit: BoxFit.cover,
        color: color,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.broken_image, color: Colors.grey, size: size),
      );
    } else {
      return Icon(_getMaterialIcon(iconPath), color: iconColor, size: size);
    }
  }


  /// Chuyển tên icon thành IconData
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
