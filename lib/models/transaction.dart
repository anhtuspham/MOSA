import 'package:mosa/models/enums.dart';

class TransactionModel {
  final int? id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String category;
  final String? note;
  final DateTime createAt;
  final DateTime? updateAt;
  final bool isSynced;
  final String syncId;

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
    this.note,
    required this.createAt,
    this.updateAt,
    this.isSynced = false,
    required this.syncId
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      title: map['title'],
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => TransactionType.outcome,
      ),
      category: map['category'],
      note: map['note'] as String?,
      createAt: DateTime.parse(map['createAt'] as String),
      updateAt: map['updateAt'] != null ? DateTime.parse(map['updateAt'] as String) : null,
      isSynced: (map['isSynced'] as int?) == 1,
      syncId: map['syncId']
    );
  }

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type.toString().split('.').last,
      'category': category,
      'note': note,
      'createAt': createAt.toIso8601String(),
      'updateAt': updateAt?.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
      'syncId': syncId
    };
  }

  TransactionModel copyWith({
    int? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    TransactionType? type,
    String? note,
    DateTime? createAt,
    DateTime? updateAt,
    bool? isSynced,
    String? syncId,


  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      type: type ?? this.type,
      note: note ?? this.note,
      createAt: createAt ?? this.createAt,
      updateAt: updateAt ?? this.updateAt,
      isSynced: isSynced ?? this.isSynced,
      syncId: syncId ?? this.syncId,
    );
  }

  @override
  String toString(){
    return 'Transaction(id: $id, title: $title, amount: $amount, date: $date, type: $type, category: $category, note: $note)';
  }
}
