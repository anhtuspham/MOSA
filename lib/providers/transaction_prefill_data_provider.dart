import 'package:flutter_riverpod/legacy.dart';
import 'package:mosa/models/category.dart';
import 'package:mosa/models/enums.dart';
import 'package:mosa/models/person.dart';

class TransactionPrefill {
  final double? amount;
  final TransactionType? type;
  final Person? person;
  final int? walletId;
  final Category? category;

  TransactionPrefill({this.amount, this.type, this.person, this.walletId, this.category});
}

final transactionPrefillDataProvider = StateProvider<TransactionPrefill?>((ref) => null);
