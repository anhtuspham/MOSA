import 'dart:developer';

enum DebtType { lent, borrowed }

enum DebtStatus { active, paid, partial }

class Debt {
  final int? id;
  final int personId;
  final double amount;
  final double paidAmount;
  final DebtType type;
  final DebtStatus status;
  final String description;
  final DateTime createdDate;
  final DateTime? dueDate;
  final int walletId;

  Debt({
    this.id,
    required this.personId,
    required this.amount,
    required this.type,
    required this.description,
    required this.createdDate,
    required this.walletId,
    this.paidAmount = 0.0,
    this.status = DebtStatus.active,
    this.dueDate,
  });

  double get remainingAmount => amount - paidAmount;

  bool get isPaid => status == DebtStatus.paid;

  bool get isOverdue => dueDate != null && DateTime.now().isAfter(dueDate!) && !isPaid;

  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      id: json['id'],
      personId: json['personId'],
      amount: json['amount'].toDouble(),
      paidAmount: json['paidAmount']?.toDouble() ?? 0.0,
      type: DebtType.values.byName(json['type']),
      status: DebtStatus.values.byName(json['status']),
      description: json['description'],
      createdDate: DateTime.fromMillisecondsSinceEpoch(json['createdDate']),
      dueDate: json['dueDate'] != null ? DateTime.fromMillisecondsSinceEpoch(json['dueDate']) : null,
      walletId: json['walletId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personId': personId,
      'amount': amount,
      'paidAmount': paidAmount,
      'type': type.name,
      'status': status.name,
      'description': description,
      'createdDate': createdDate.millisecondsSinceEpoch,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'walletId': walletId,
    };
  }

  Debt copyWith({
    int? id,
    int? personId,
    double? amount,
    double? paidAmount,
    DebtType? type,
    DebtStatus? status,
    String? description,
    DateTime? createdDate,
    DateTime? dueDate,
    int? walletId,
  }) {
    return Debt(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      amount: amount ?? this.amount,
      paidAmount: paidAmount ?? this.paidAmount,
      type: type ?? this.type,
      status: status ?? this.status,
      description: description ?? this.description,
      createdDate: createdDate ?? this.createdDate,
      dueDate: dueDate ?? this.dueDate,
      walletId: walletId ?? this.walletId,
    );
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is Debt && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DebtInfo {
  final double totalDebt;
  final double totalDebtPaid;
  final double totalDebtRemaining;

  DebtInfo({required this.totalDebt,required this.totalDebtPaid, required this.totalDebtRemaining});
}
