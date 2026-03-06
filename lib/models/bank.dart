import 'package:mosa/utils/app_icons.dart';

/// Model lưu trữ thông tin ngân hàng
class Bank {
  final int? id;
  final String name;
  final String iconPath;

  Bank({this.id, required this.name, required this.iconPath});

  /// Tạo Bank từ JSON
  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      id: json['id'] as int?,
      name: json['name'] as String,
      iconPath: json['iconPath'] as String? ?? AppIcons.logoMbBank,
    );
  }

  /// Tạo Bank từ Map (database)
  factory Bank.fromMap(Map<String, dynamic> map) {
    return Bank(
      id: map['id'] as int?,
      name: map['name'] as String,
      iconPath: map['iconPath'] as String? ?? AppIcons.logoMbBank,
    );
  }

  /// Chuyển Bank sang Map (database)
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'iconPath': iconPath};
  }

  /// Tạo bản sao với các trường được cập nhật
  Bank copyWith({int? id, String? name, String? iconPath}) {
    return Bank(
      id: id ?? this.id,
      name: name ?? this.name,
      iconPath: iconPath ?? this.iconPath,
    );
  }
}
