/// Loại nợ: cho vay (lent) hoặc đi vay (borrowed)
enum DebtType {
  /// Cho vay
  lent,
  /// Đi vay
  borrowed;

  /// Chuyển từ String trong Database sang DebtType
  static DebtType fromString(String? value) {
    return DebtType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DebtType.borrowed,
    );
  }
}

/// Trạng thái nợ: đang hoạt động (active), đã trả (paid), trả một phần (partial)
enum DebtStatus {
  /// Nợ đang hoạt động (chưa trả hoặc chưa trả hết)
  active,
  /// Đã trả hết
  paid,
  /// Trả một phần
  partial,
  /// Trạng thái không xác định (dùng để bắt lỗi DB)
  unknown;

  /// Chuyển từ String trong Database sang DebtStatus
  static DebtStatus fromString(String? value) {
    return DebtStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DebtStatus.unknown,
    );
  }
}

/// Model lưu trữ thông tin khoản nợ/cho vay
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

  /// Số tiền còn lại cần trả
  double get remainingAmount => amount - paidAmount;

  /// Kiểm tra đã trả hết chưa
  bool get isPaid => status == DebtStatus.paid;

  /// Kiểm tra có quá hạn không
  bool get isOverdue =>
      dueDate != null && DateTime.now().isAfter(dueDate!) && !isPaid;

  /// Tạo Debt từ JSON
  /// Tạo Debt từ JSON
  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      id: json['id'] as int?,
      personId: json['personId'] as int,
      amount: (json['amount'] as num).toDouble(),
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
      type: DebtType.fromString(json['type'] as String?),
      status: DebtStatus.fromString(json['status'] as String?),
      description: json['description'] as String,
      createdDate: DateTime.parse(json['createdDate'] as String),
      dueDate:
          json['dueDate'] != null
              ? DateTime.parse(json['dueDate'] as String)
              : null,
      walletId: json['walletId'] as int,
    );
  }

  /// Chuyển Debt sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personId': personId,
      'amount': amount,
      'paidAmount': paidAmount,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'description': description,
      'createdDate': createdDate.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'walletId': walletId,
    };
  }

  /// Tạo Debt từ Map (database)
  factory Debt.fromMap(Map<String, dynamic> map) {
    return Debt(
      id: map['id'] as int?,
      personId: map['personId'] as int,
      amount: (map['amount'] as num).toDouble(),
      paidAmount: (map['paidAmount'] as num?)?.toDouble() ?? 0.0,
      type: DebtType.fromString(map['type'] as String?),
      status: DebtStatus.fromString(map['status'] as String?),
      description: map['description'] as String,
      createdDate: DateTime.parse(map['createdDate'] as String),
      dueDate:
          map['dueDate'] != null
              ? DateTime.parse(map['dueDate'] as String)
              : null,
      walletId: map['walletId'] as int,
    );
  }

  /// Chuyển Debt sang Map (database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'personId': personId,
      'amount': amount,
      'paidAmount': paidAmount,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'description': description,
      'createdDate': createdDate.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'walletId': walletId,
    };
  }

  /// Tạo bản sao với các trường được cập nhật
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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Debt && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Model lưu trữ thông tin tổng hợp nợ
class DebtInfo {
  final double totalDebt;
  final double totalDebtPaid;
  final double totalDebtRemaining;

  DebtInfo({
    required this.totalDebt,
    required this.totalDebtPaid,
    required this.totalDebtRemaining,
  });
}
