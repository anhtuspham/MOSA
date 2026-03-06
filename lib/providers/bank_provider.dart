import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/bank.dart';
import '../services/bank_service.dart';

/// Provider lấy danh sách ngân hàng
final bankListProvider = FutureProvider<List<Bank>>((ref) {
  return BankService.loadBank();
});

/// Provider lưu trữ ngân hàng được chọn
final selectedBankProvider = StateProvider<Bank?>((ref) => null);
