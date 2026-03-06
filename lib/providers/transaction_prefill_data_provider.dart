import 'package:flutter_riverpod/legacy.dart';
import 'package:mosa/models/category.dart';
import 'package:mosa/models/enums.dart';
import 'package:mosa/models/person.dart';

/// Lưu trữ dữ liệu tạm thời để điền trước khi tạo giao dịch
class TransactionPrefill {
  /// Số tiền giao dịch
  final double? amount;
  /// Loại giao dịch
  final TransactionType? type;
  /// Người liên quan (cho vay/đi vay)
  final Person? person;
  /// ID ví
  final int? walletId;
  /// Danh mục giao dịch
  final Category? category;

  TransactionPrefill({
    this.amount,
    this.type,
    this.person,
    this.walletId,
    this.category,
  });
}

/// Provider lưu trữ dữ liệu điền trước cho giao dịch
final transactionPrefillDataProvider = StateProvider<TransactionPrefill?>(
  (ref) => null,
);
