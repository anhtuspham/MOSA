/// Model lưu trữ thông tin người cho vay/đi vay
class Person {
  final int? id;
  final String name;
  final String? iconPath;
  final DateTime? createAt;
  final DateTime? updateAt;

  Person({
    this.id,
    required this.name,
    this.iconPath = 'assets/images/icon.png',
    this.createAt,
    this.updateAt,
  });

  /// Tạo Person từ JSON
  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] as int?,
      name: json['name'] as String,
      iconPath: json['iconPath'] as String?,
      createAt: json['createAt'] != null
          ? DateTime.parse(json['createAt'] as String)
          : null,
      updateAt: json['updateAt'] != null
          ? DateTime.parse(json['updateAt'] as String)
          : null,
    );
  }

  /// Tạo Person từ Map (database)
  factory Person.fromMap(Map<String, dynamic> map) {
    return Person(
      id: map['id'] as int?,
      name: map['name'] as String,
      iconPath: map['iconPath'] as String?,
      createAt: map['createAt'] != null
          ? DateTime.parse(map['createAt'] as String)
          : null,
      updateAt: map['updateAt'] != null
          ? DateTime.parse(map['updateAt'] as String)
          : null,
    );
  }

  /// Chuyển Person sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconPath': iconPath,
      'createAt': createAt?.toIso8601String(),
      'updateAt': updateAt?.toIso8601String(),
    };
  }

  /// Chuyển Person sang Map (database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconPath': iconPath,
      'createAt': createAt?.toIso8601String(),
      'updateAt': updateAt?.toIso8601String(),
    };
  }

  /// Tạo Person rỗng
  factory Person.empty() =>
      Person(id: 0, name: 'name', iconPath: 'assets/images/icon.png');

  /// Tạo bản sao với các trường được cập nhật
  Person copyWith({
    int? id,
    String? name,
    String? iconPath,
    DateTime? createAt,
    DateTime? updateAt,
  }) {
    return Person(
      id: id ?? this.id,
      name: name ?? this.name,
      iconPath: iconPath ?? this.iconPath,
      createAt: createAt ?? this.createAt,
      updateAt: updateAt ?? this.updateAt,
    );
  }
}
