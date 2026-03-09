import 'dart:convert';

class Budget {
  final int? id;
  final String categoryId;
  final double amount;
  final int month;
  final int year;

  Budget({
    this.id,
    required this.categoryId,
    required this.amount,
    required this.month,
    required this.year,
  });

  Budget copyWith({
    int? id,
    String? categoryId,
    double? amount,
    int? month,
    int? year,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      month: month ?? this.month,
      year: year ?? this.year,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'amount': amount,
      'month': month,
      'year': year,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id']?.toInt(),
      categoryId: map['categoryId'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      month: map['month']?.toInt() ?? 1,
      year: map['year']?.toInt() ?? 2024,
    );
  }

  String toJson() => json.encode(toMap());

  factory Budget.fromJson(String source) => Budget.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Budget(id: $id, categoryId: $categoryId, amount: $amount, month: $month, year: $year)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Budget &&
      other.id == id &&
      other.categoryId == categoryId &&
      other.amount == amount &&
      other.month == month &&
      other.year == year;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      categoryId.hashCode ^
      amount.hashCode ^
      month.hashCode ^
      year.hashCode;
  }
}
