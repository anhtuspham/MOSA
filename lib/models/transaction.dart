class TransactionModel {
  final int? id;
  final String title;
  final double amount;
  final DateTime date;
  final String type; // income or outcome
  final String category;
  final String? note;

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
    this.note,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      title: map['title'],
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      type: map['type'],
      category: map['category'],
      note: map['note'] as String?,
    );
  }

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type,
      'category': category,
      'note': note,
    };
  }

  TransactionModel copyWith({
    int? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? type,
    String? note,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      type: type ?? this.type,
      note: note ?? this.note,
    );
  }

  @override
  String toString(){
    return 'Transaction(id: $id, title: $title, amount: $amount, date: $date, type: $type, category: $category, note: $note)';
  }
}
