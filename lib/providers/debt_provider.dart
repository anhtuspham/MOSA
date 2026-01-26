import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mosa/models/debt.dart';
import 'package:mosa/models/enums.dart';
import 'package:mosa/models/transaction.dart';
import 'package:mosa/providers/person_provider.dart';
import 'package:mosa/utils/utils.dart';

import '../models/category.dart';
import '../services/database_service.dart';
import 'category_provider.dart';
import 'database_service_provider.dart';
import 'package:mosa/providers/wallet_provider.dart';
import 'package:mosa/providers/transaction_provider.dart';

class DebtNotifier extends AsyncNotifier<List<Debt>> {
  DatabaseService get _databaseService => ref.read(databaseServiceProvider);

  @override
  FutureOr<List<Debt>> build() async {
    return await _databaseService.getAllDebt();
  }

  Future<void> refreshListDebt() async {
    try {
      final debts = await _databaseService.getAllDebt();
      if (debts != state.value) {
        state = AsyncData(debts);
      }
    } catch (e) {
      log('Error when refresh list debt $e', name: 'debt_provider');
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> createDebt(Debt debt) async {
    state = const AsyncLoading();

    try {
      int id = await _databaseService.createDebt(debt);
      final lendCategory = await ref.read(categoryByNameProvider('Cho vay').future);
      final borrowCategory = await ref.read(categoryByNameProvider('Mượn').future);
      final newDebt = debt.copyWith(id: id);
      bool isLent = debt.type == DebtType.lent;

      // Get person name for transaction title
      final person = ref.watch(personByIdProvider(newDebt.personId));
      final personName = person?.name ?? 'Unknown';

      final lendTransaction = TransactionModel(
        title: 'Cho vay: $personName',
        amount: debt.amount,
        date: DateTime.now(),
        type: TransactionType.lend,
        createAt: DateTime.now(),
        categoryId: lendCategory?.id,
        walletId: debt.walletId,
        dueDate: debt.dueDate,
        syncId: generateSyncId(),
      );

      final borrowingTransaction = TransactionModel(
        title: 'Vay từ: $personName',
        amount: debt.amount,
        date: DateTime.now(),
        type: TransactionType.borrowing,
        createAt: DateTime.now(),
        categoryId: borrowCategory?.id,
        walletId: debt.walletId,
        dueDate: debt.dueDate,
        syncId: generateSyncId(),
      );

      await _databaseService.insertTransaction(isLent ? lendTransaction : borrowingTransaction);

      // Refresh wallet provider to update balance
      await ref.read(walletProvider.notifier).refreshWallet();

      // Refresh transaction provider to show new transaction
      await ref.read(transactionProvider.notifier).refreshTransactions();

      state = AsyncData([newDebt, ...state.requireValue]);
      refreshListDebt();
    } catch (e) {
      log('Error when create debt $e');
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> updateDebt(Debt debt) async {
    state = const AsyncLoading();
    try {
      await _databaseService.updateDebt(debt);
      final index = state.requireValue.indexWhere((element) => element == debt);
      if (index != -1) {
        state = AsyncData([...state.requireValue.sublist(0, index), debt, ...state.requireValue.sublist(index + 1)]);
      }
    } catch (e) {
      log('Error when update debt $e');
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> deleteDebt(Debt debt) async {
    state = const AsyncLoading();
    try {
      await _databaseService.deleteDebt(debt);
      state = AsyncData(state.requireValue.where((element) => element != debt).toList());
    } catch (e) {
      log('Error when delete debt $e');
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> payDebt(int debtId, double paymentAmount, int walletId) async {
    state = const AsyncLoading();
    try {
      final currentDebts = state.requireValue;
      final debtIndex = currentDebts.indexWhere((element) => element.id == debtId);
      if (debtIndex == -1) throw 'Không tìm thấy khoản nợ';
      final currentDebt = currentDebts[debtIndex];

      final remainingAmount = currentDebt.amount - currentDebt.paidAmount;
      if (paymentAmount > remainingAmount) throw 'Số tiền thanh toán vượt quá khoản nợ';

      final newPaidAmount = currentDebt.paidAmount + paymentAmount;
      final newStatus = newPaidAmount >= currentDebt.amount ? DebtStatus.paid : DebtStatus.partial;
      final newDebt = currentDebt.copyWith(paidAmount: newPaidAmount, status: newStatus);

      await _databaseService.updateDebt(newDebt);

      // Get person name for transaction title
      final person = ref.watch(personByIdProvider(newDebt.personId));
      // final person = await _databaseService.getPersonById(newDebt.personId);
      final personName = person?.name ?? 'Unknown';

      final transaction = TransactionModel(
        title: 'Trả nợ cho: $personName',
        amount: paymentAmount,
        date: DateTime.now(),
        type: TransactionType.repayment,
        createAt: DateTime.now(),
        walletId: walletId,
        syncId: generateSyncId(),
      );

      await _databaseService.insertTransaction(transaction);

      // Refresh wallet provider to update balance
      await ref.read(walletProvider.notifier).refreshWallet();

      // Refresh transaction provider to show new transaction
      await ref.read(transactionProvider.notifier).refreshTransactions();

      final updateDebt = [...currentDebts];
      updateDebt[debtIndex] = newDebt;
      state = AsyncData(updateDebt);
    } catch (e) {
      log('Error when pay debt $e');
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> collectDebt(int debtId, double paymentAmount, int walletId) async {
    state = const AsyncLoading();
    try {
      final currentDebts = state.requireValue;
      final debtIndex = currentDebts.indexWhere((element) => element.id == debtId);
      if (debtIndex == -1) throw 'Không tìm thấy khoản nợ';

      final currentDebt = currentDebts[debtIndex];

      final remainingAmount = currentDebt.amount - currentDebt.paidAmount;
      if (paymentAmount > remainingAmount) throw 'Số tiền thanh toán vượt quá khoản nợ';

      final newPaidAmount = currentDebt.paidAmount + paymentAmount;
      final newStatus = newPaidAmount >= currentDebt.amount ? DebtStatus.paid : DebtStatus.partial;
      final newDebt = currentDebt.copyWith(paidAmount: newPaidAmount, status: newStatus);

      await _databaseService.updateDebt(newDebt);

      // Get person name for transaction title
      final person = ref.watch(personByIdProvider(newDebt.personId));
      // final person = await _databaseService.getPersonById(newDebt.personId);
      final personName = person?.name ?? 'Unknown';

      final transaction = TransactionModel(
        title: '$personName trả nợ',
        amount: paymentAmount,
        date: DateTime.now(),
        type: TransactionType.debtCollection,
        createAt: DateTime.now(),
        walletId: walletId,
        syncId: generateSyncId(),
      );
      await _databaseService.insertTransaction(transaction);

      // Refresh wallet provider to update balance
      await ref.read(walletProvider.notifier).refreshWallet();

      // Refresh transaction provider to show new transaction
      await ref.read(transactionProvider.notifier).refreshTransactions();

      final updateDebt = [...currentDebts];
      updateDebt[debtIndex] = newDebt;
      state = AsyncData(updateDebt);
    } catch (e) {
      log('Error when collect debt $e');
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }
}

final debtProvider = AsyncNotifierProvider<DebtNotifier, List<Debt>>(DebtNotifier.new);

final debtByPersonProvider = Provider.family<List<Debt>, int>((ref, personId) {
  final debts = ref.watch(debtProvider).value ?? [];
  return debts.where((debt) => debt.personId == personId).toList();
});

final debtByTypeProvider = Provider.family<List<Debt>, DebtType>((ref, type) {
  final debts = ref.watch(debtProvider).value ?? [];
  return debts.where((debt) => debt.type == type).toList();
});

final debtSummaryByTypeProvider = Provider.family<Map<int, double>, DebtType>((ref, type) {
  final debts = ref.watch(debtByTypeProvider(type));
  final summary = <int, double>{};
  for (var debt in debts) {
    final remaining = debt.remainingAmount;
    summary[debt.personId] = (summary[debt.personId] ?? 0) + remaining;
  }
  return summary;
});

final totalDebtProvider = Provider<Map<String, double>>((ref) {
  final debts = ref.watch(debtProvider).value ?? [];
  double totalLent = 0;
  double totalBorrowed = 0;

  for (final debt in debts) {
    if (debt.status != DebtStatus.paid) {
      final remaining = debt.amount - debt.paidAmount;
      if (debt.type == DebtType.lent) {
        totalLent += remaining;
      } else {
        totalBorrowed += remaining;
      }
    }
  }
  return {'lent': totalLent, 'borrowed': totalBorrowed};
});
