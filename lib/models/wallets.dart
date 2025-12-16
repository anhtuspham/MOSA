import 'package:mosa/utils/app_icons.dart';

class Wallet {
  final int? id;
  final String name;
  final String iconPath;
  final double balance;
  final TypeWallet typeWallet;        // 'cash', 'bank', 'ewallet', 'credit_card'
  final bool isDefault;
  final bool isActive;
  final DateTime createAt;
  final DateTime? updateAt;
  final bool isSynced;
  final String syncId;

  Wallet({
    this.id,
    required this.name,
    this.iconPath = AppIcons.logoCash,
    required this.balance,
    required this.typeWallet,
    this.isDefault = false,
    this.isActive = true,
    required this.createAt,
    this.updateAt,
    this.isSynced = false,
    required this.syncId,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      name: json['name'] as String,
      iconPath: json['iconPath'] as String? ?? AppIcons.logoCash,
      balance: (json['balance'] as num).toDouble(),
      typeWallet: json['typeWallet'] as TypeWallet? ?? TypeWallet(),
      isDefault: json['isDefault'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      createAt: DateTime.now(),
      updateAt: DateTime.now(),
      isSynced: json['isSynced'] as bool? ?? false,
      syncId: json['syncId'] as String? ?? '',
    );
  }

  factory Wallet.fromMap(Map<String, dynamic> map) {
    return Wallet(
      id: map['id'] as int?,
      name: map['name'] as String,
      iconPath: map['iconPath'] as String? ?? AppIcons.logoCash,
      balance: (map['balance'] as num).toDouble(),
      typeWallet: map['typeWallet'] as TypeWallet? ?? TypeWallet(),
      isDefault: (map['isDefault'] as int?) == 1,
      isActive: (map['isActive'] as int?) == 1,
      createAt: DateTime.parse(map['createAt'] as String),
      updateAt: map['updateAt'] != null
          ? DateTime.parse(map['updateAt'] as String)
          : null,
      isSynced: (map['isSynced'] as int?) == 1,
      syncId: map['syncId'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconPath': iconPath,
      'balance': balance,
      'typeWallet': typeWallet,
      'isDefault': isDefault ? 1 : 0,
      'isActive': isActive ? 1 : 0,
      'createAt': createAt.toIso8601String(),
      'updateAt': updateAt?.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
      'syncId': syncId,
    };
  }

  Wallet copyWith({
    int? id,
    String? name,
    String? iconPath,
    double? balance,
    TypeWallet? typeWallet,
    bool? isDefault,
    bool? isActive,
    DateTime? createAt,
    DateTime? updateAt,
    bool? isSynced,
    String? syncId,
  }) {
    return Wallet(
      id: id ?? this.id,
      name: name ?? this.name,
      iconPath: iconPath ?? this.iconPath,
      balance: balance ?? this.balance,
      typeWallet: typeWallet ?? this.typeWallet,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      createAt: createAt ?? this.createAt,
      updateAt: updateAt ?? this.updateAt,
      isSynced: isSynced ?? this.isSynced,
      syncId: syncId ?? this.syncId,
    );
  }

  // @override
  // String toString() {
  //   return 'Wallet(id: $id, name: $name, balance: $balance, type: $typeWallet, isDefault: $isDefault, isActive: $isActive)';
  // }
}

class TypeWallet{
  final int? id;
  final String? name;
  final String? iconPath;

  TypeWallet({
    this.id,
    this.name,
    this.iconPath,
  });

  factory TypeWallet.fromJson(Map<String, dynamic> json) {
    return TypeWallet(
      id: json['id'] as int,
      name: json['name'] as String,
      iconPath: json['iconPath'] as String? ?? AppIcons.logoCash,
    );
  }

  factory TypeWallet.fromMap(Map<String, dynamic> map) {
    return TypeWallet(
      id: map['id'] as int?,
      name: map['name'] as String,
      iconPath: map['iconPath'] as String? ?? AppIcons.logoCash,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconPath': iconPath
    };
  }

  TypeWallet copyWith({
    int? id,
    String? name,
    String? iconPath
  }) {
    return TypeWallet(
      id: id ?? this.id,
      name: name ?? this.name,
      iconPath: iconPath ?? this.iconPath,
    );
  }
}