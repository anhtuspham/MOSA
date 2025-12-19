import 'package:mosa/utils/app_icons.dart';

class Bank {
  final int? id;
  final String name;
  final String iconPath;

  Bank({this.id, required this.name, required this.iconPath});

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      id: json['id'] as int?,
      name: json['name'] as String,
      iconPath: json['iconPath'] as String? ?? AppIcons.logoMbBank,
    );
  }

  factory Bank.fromMap(Map<String, dynamic> map) {
    return Bank(
      id: map['id'] as int?,
      name: map['name'] as String,
      iconPath: map['iconPath'] as String? ?? AppIcons.logoMbBank,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'iconPath': iconPath};
  }

  Bank copyWith({int? id, String? name, String? iconPath}) {
    return Bank(
      id: id ?? this.id,
      name: name ?? this.name,
      iconPath: iconPath ?? this.iconPath,
    );
  }
}
