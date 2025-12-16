import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/bank.dart';
import '../services/bank_service.dart';

final bankListProvider = FutureProvider<List<Bank>>((ref) {
  return BankService.loadBank();
},);

final selectedBankProvider = StateProvider<Bank?>((ref) => null);