import 'package:mosa/models/enums.dart';
import 'package:mosa/utils/utils.dart';

class TransactionModel {
  final int? id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String categoryId;
  final String? note;
  final DateTime createAt;
  final DateTime? updateAt;
  final bool isSynced;
  final String syncId;
  final int walletId;

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.categoryId,
    this.note,
    required this.createAt,
    this.updateAt,
    this.isSynced = false,
    required this.syncId,
    required this.walletId,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['categoryId'] as String,
      walletId: json['walletId'] as int,
      date: DateTime.parse(json['date'] as String),
      type: getTransactionType(json['type'] as String),
      note: json['note'] as String?,
      createAt: DateTime.now(),
      updateAt: DateTime.now(),
      isSynced: json['isSynced'] as bool? ?? false,
      syncId: json['syncId'] as String? ?? '',
    );
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      title: map['title'],
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => TransactionType.expense,
      ),
      categoryId: map['categoryId'],
      note: map['note'] as String?,
      createAt: DateTime.parse(map['createAt'] as String),
      updateAt: map['updateAt'] != null ? DateTime.parse(map['updateAt'] as String) : null,
      isSynced: (map['isSynced'] as int?) == 1,
      syncId: map['syncId'],
      walletId: map['walletId'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type.toString().split('.').last,
      'categoryId': categoryId,
      'note': note,
      'createAt': createAt.toIso8601String(),
      'updateAt': updateAt?.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
      'syncId': syncId,
      'walletId': walletId,
    };
  }

  TransactionModel copyWith({
    int? id,
    String? title,
    double? amount,
    String? categoryId,
    DateTime? date,
    TransactionType? type,
    String? note,
    DateTime? createAt,
    DateTime? updateAt,
    bool? isSynced,
    String? syncId,
    int? walletId,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      type: type ?? this.type,
      note: note ?? this.note,
      createAt: createAt ?? this.createAt,
      updateAt: updateAt ?? this.updateAt,
      isSynced: isSynced ?? this.isSynced,
      syncId: syncId ?? this.syncId,
      walletId: walletId ?? this.walletId,
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, title: $title, amount: $amount, date: $date, type: $type, categoryId: $categoryId, note: $note)';
  }
}
