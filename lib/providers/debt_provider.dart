import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mosa/config/app_config.dart';
import 'package:mosa/models/debt.dart';
import 'package:mosa/models/enums.dart';
import 'package:mosa/models/transaction.dart';
import 'package:mosa/providers/person_provider.dart';
import 'package:mosa/utils/utils.dart';

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
      appConfig.printLog('i', 'all debts: ${debts.map((e) => e.toJson())}');
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
      final person = ref.read(personByIdProvider(newDebt.personId));
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
      final payBackCategory = await ref.read(categoryByNameProvider('Trả nợ').future);

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
      final person = ref.read(personByIdProvider(newDebt.personId));
      final personName = person?.name ?? 'Unknown';

      final transaction = TransactionModel(
        title: 'Trả nợ cho: $personName',
        amount: paymentAmount,
        date: DateTime.now(),
        type: TransactionType.repayment,
        createAt: DateTime.now(),
        categoryId: payBackCategory?.id,
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
      final collectCategory = await ref.read(categoryByNameProvider('Thu nợ').future);

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
      final person = ref.read(personByIdProvider(newDebt.personId));
      final personName = person?.name ?? 'Unknown';

      final transaction = TransactionModel(
        title: '$personName trả nợ',
        amount: paymentAmount,
        date: DateTime.now(),
        type: TransactionType.debtCollection,
        createAt: DateTime.now(),
        categoryId: collectCategory?.id,
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

  /// Pay debt by person - auto-distribute payment across all active debts of that person (FIFO)
  /// Used when user wants to pay off what they borrowed (Debts.Borrowed)
  Future<void> payDebtByPerson(int personId, double paymentAmount, int walletId) async {
    state = const AsyncLoading();
    try {
      final payBackCategory = await ref.read(categoryByNameProvider('Trả nợ').future);
      final person = ref.read(personByIdProvider(personId));
      final personName = person?.name ?? 'Unknown';

      // Get all active debts for this person (borrowed type)
      final allDebts = await _databaseService.getActiveDebtsByPersonAndType(personId, DebtType.borrowed);

      if (allDebts.isEmpty) throw 'Không có khoản nợ nào với người này';

      double remainingPayment = paymentAmount;
      final List<Debt> updatedDebts = [];

      // FIFO: pay off oldest debts first
      for (final debt in allDebts) {
        if (remainingPayment <= 0) break;

        final debtRemaining = debt.amount - debt.paidAmount;
        final paymentForThisDebt = remainingPayment >= debtRemaining ? debtRemaining : remainingPayment;

        final newPaidAmount = debt.paidAmount + paymentForThisDebt;
        final newStatus = newPaidAmount >= debt.amount ? DebtStatus.paid : DebtStatus.partial;
        final updatedDebt = debt.copyWith(paidAmount: newPaidAmount, status: newStatus);

        await _databaseService.updateDebt(updatedDebt);
        updatedDebts.add(updatedDebt);

        remainingPayment -= paymentForThisDebt;
      }

      // Allow small floating point tolerance (0.01) to handle rounding errors
      // This is acceptable since amounts are typically in VND where 0.01 is negligible
      if (remainingPayment > 0.01) {
        throw 'Số tiền trả vượt quá tổng nợ';
      }

      // Create ONE transaction for the total payment amount
      final transaction = TransactionModel(
        title: 'Trả nợ cho: $personName',
        amount: paymentAmount,
        date: DateTime.now(),
        type: TransactionType.repayment,
        createAt: DateTime.now(),
        categoryId: payBackCategory?.id,
        walletId: walletId,
        syncId: generateSyncId(),
      );
      await _databaseService.insertTransaction(transaction);

      // Refresh wallet and transaction providers
      await ref.read(walletProvider.notifier).refreshWallet();
      await ref.read(transactionProvider.notifier).refreshTransactions();

      // Update state: merge updated debts into current state
      final currentDebts = state.requireValue;
      final updatedState = currentDebts.map((debt) {
        return updatedDebts.firstWhere((u) => u.id == debt.id, orElse: () => debt);
      }).toList();
      state = AsyncData(updatedState);
    } catch (e) {
      log('Error when pay debt by person: $e');
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  /// Collect debt by person - auto-distribute collection across all active debts of that person (FIFO)
  /// Used when user wants to collect what they lent (Debts.Lent)
  Future<void> collectDebtByPerson(int personId, double paymentAmount, int walletId) async {
    state = const AsyncLoading();
    try {
      final collectCategory = await ref.read(categoryByNameProvider('Thu nợ').future);
      final person = ref.read(personByIdProvider(personId));
      final personName = person?.name ?? 'Unknown';

      // Get all active debts for this person (lent type)
      final allDebts = await _databaseService.getActiveDebtsByPersonAndType(personId, DebtType.lent);

      if (allDebts.isEmpty) throw 'Không có khoản nợ nào từ người này';

      double remainingCollection = paymentAmount;
      final List<Debt> updatedDebts = [];
      final allDebtRemaining = allDebts.fold(0.0, (previousValue, element) => previousValue + element.remainingAmount);
      if(allDebtRemaining < paymentAmount){
        throw 'Số tiền thu vượt quá tổng nợ';
      }

      // FIFO: collect from oldest debts first
      for (final debt in allDebts) {
        if (remainingCollection <= 0) break;

        final debtRemaining = debt.amount - debt.paidAmount;
        final collectionForThisDebt = remainingCollection >= debtRemaining ? debtRemaining : remainingCollection;

        final newPaidAmount = debt.paidAmount + collectionForThisDebt;
        final newStatus = newPaidAmount >= debt.amount ? DebtStatus.paid : DebtStatus.partial;
        final updatedDebt = debt.copyWith(paidAmount: newPaidAmount, status: newStatus);

        await _databaseService.updateDebt(updatedDebt);
        updatedDebts.add(updatedDebt);

        remainingCollection -= collectionForThisDebt;
      }

      // Allow small floating point tolerance (0.01) to handle rounding errors
      // This is acceptable since amounts are typically in VND where 0.01 is negligible
      if (remainingCollection > 0.01) {
        throw 'Số tiền thu vượt quá tổng nợ';
      }

      // Create ONE transaction for the total collection amount
      final transaction = TransactionModel(
        title: '$personName trả nợ',
        amount: paymentAmount,
        date: DateTime.now(),
        type: TransactionType.debtCollection,
        createAt: DateTime.now(),
        categoryId: collectCategory?.id,
        walletId: walletId,
        syncId: generateSyncId(),
      );
      await _databaseService.insertTransaction(transaction);

      // Refresh wallet and transaction providers
      await ref.read(walletProvider.notifier).refreshWallet();
      await ref.read(transactionProvider.notifier).refreshTransactions();

      // Update state: merge updated debts into current state
      final currentDebts = state.requireValue;
      final updatedState = currentDebts.map((debt) {
        return updatedDebts.firstWhere((u) => u.id == debt.id, orElse: () => debt);
      }).toList();
      state = AsyncData(updatedState);
    } catch (e) {
      log('Error when collect debt by person: $e');
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  /// Pay a SINGLE specific debt (for when user selects a specific debt to pay)
  /// Used when user wants to pay back what they borrowed (Debts.Borrowed)
  Future<void> paySingleDebt(int debtId, double paymentAmount, int walletId) async {
    state = const AsyncLoading();
    try {
      final payCategory = await ref.read(categoryByNameProvider('Trả nợ').future);
      
      // Get the specific debt
      final currentDebts = state.requireValue;
      final debtIndex = currentDebts.indexWhere((d) => d.id == debtId);
      
      if (debtIndex == -1) throw 'Không tìm thấy khoản nợ';
      
      final debt = currentDebts[debtIndex];
      final person = ref.read(personByIdProvider(debt.personId));
      final personName = person?.name ?? 'Unknown';
      
      // Validate payment amount
      final remainingAmount = debt.amount - debt.paidAmount;
      if (paymentAmount > remainingAmount + 0.01) { // Allow small floating point tolerance
        throw 'Số tiền trả vượt quá số nợ còn lại (${remainingAmount.toStringAsFixed(0)})';
      }
      
      // Update debt
      final newPaidAmount = debt.paidAmount + paymentAmount;
      final newStatus = newPaidAmount >= debt.amount ? DebtStatus.paid : DebtStatus.partial;
      final updatedDebt = debt.copyWith(paidAmount: newPaidAmount, status: newStatus);
      
      await _databaseService.updateDebt(updatedDebt);
      
      // Create transaction for the payment
      final transaction = TransactionModel(
        title: 'Trả nợ $personName',
        amount: paymentAmount,
        date: DateTime.now(),
        type: TransactionType.repayment,
        createAt: DateTime.now(),
        categoryId: payCategory?.id,
        walletId: walletId,
        syncId: generateSyncId(),
      );
      await _databaseService.insertTransaction(transaction);
      
      // Refresh wallet and transaction providers
      await ref.read(walletProvider.notifier).refreshWallet();
      await ref.read(transactionProvider.notifier).refreshTransactions();
      
      // Update state
      final updatedList = [...currentDebts];
      updatedList[debtIndex] = updatedDebt;
      state = AsyncData(updatedList);
    } catch (e) {
      log('Error when pay single debt: $e');
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  /// Collect a SINGLE specific debt (for when user selects a specific debt to collect)
  /// Used when user wants to collect what they lent (Debts.Lent)
  Future<void> collectSingleDebt(int debtId, double collectionAmount, int walletId) async {
    state = const AsyncLoading();
    try {
      final collectCategory = await ref.read(categoryByNameProvider('Thu nợ').future);
      
      // Get the specific debt
      final currentDebts = state.requireValue;
      final debtIndex = currentDebts.indexWhere((d) => d.id == debtId);
      
      if (debtIndex == -1) throw 'Không tìm thấy khoản nợ';
      
      final debt = currentDebts[debtIndex];
      final person = ref.read(personByIdProvider(debt.personId));
      final personName = person?.name ?? 'Unknown';
      
      // Validate collection amount
      final remainingAmount = debt.amount - debt.paidAmount;
      if (collectionAmount > remainingAmount + 0.01) { // Allow small floating point tolerance
        throw 'Số tiền thu vượt quá số nợ còn lại (${remainingAmount.toStringAsFixed(0)})';
      }
      
      // Update debt
      final newPaidAmount = debt.paidAmount + collectionAmount;
      final newStatus = newPaidAmount >= debt.amount ? DebtStatus.paid : DebtStatus.partial;
      final updatedDebt = debt.copyWith(paidAmount: newPaidAmount, status: newStatus);
      
      await _databaseService.updateDebt(updatedDebt);
      
      // Create transaction for the collection
      final transaction = TransactionModel(
        title: '$personName trả nợ',
        amount: collectionAmount,
        date: DateTime.now(),
        type: TransactionType.debtCollection,
        createAt: DateTime.now(),
        categoryId: collectCategory?.id,
        walletId: walletId,
        syncId: generateSyncId(),
      );
      await _databaseService.insertTransaction(transaction);
      
      // Refresh wallet and transaction providers
      await ref.read(walletProvider.notifier).refreshWallet();
      await ref.read(transactionProvider.notifier).refreshTransactions();
      
      // Update state
      final updatedList = [...currentDebts];
      updatedList[debtIndex] = updatedDebt;
      state = AsyncData(updatedList);
    } catch (e) {
      log('Error when collect single debt: $e');
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

final totalDebtByPersonProvider = Provider.family<DebtInfo, int>((ref, personId) {
  final debts = ref.watch(debtByPersonProvider(personId));
  double totalDebt = 0;
  double totalDebtPaid = 0;
  double totalDebtRemaining = 0;
  for (var debt in debts) {
    totalDebt += debt.amount;
    totalDebtPaid += debt.paidAmount;
    totalDebtRemaining += debt.remainingAmount;
  }
  return DebtInfo(totalDebt: totalDebt, totalDebtPaid: totalDebtPaid, totalDebtRemaining: totalDebtRemaining);
});

final debtByTypeProvider = Provider.family<List<Debt>, DebtType>((ref, type) {
  final debts = ref.watch(debtProvider).value ?? [];
  return debts.where((debt) => debt.type == type).toList();
});

/// Map<personId, remainingAmount> cho các debts CHƯA hoàn thành (active / partial)
final debtSummaryByTypeProvider = Provider.family<Map<int, double>, DebtType>((ref, type) {
  final debts = ref.watch(debtByTypeProvider(type));
  final summary = <int, double>{};
  for (var debt in debts) {
    if (debt.status == DebtStatus.paid) continue; // bỏ qua debts đã hoàn thành
    summary[debt.personId] = (summary[debt.personId] ?? 0) + debt.remainingAmount;
  }
  return summary;
});

/// Map<personId, totalAmount> cho các debts ĐÃ hoàn thành (paid)
final debtSummaryPaidByTypeProvider = Provider.family<Map<int, double>, DebtType>((ref, type) {
  final debts = ref.watch(debtByTypeProvider(type));
  final summary = <int, double>{};
  for (var debt in debts) {
    if (debt.status != DebtStatus.paid) continue;
    summary[debt.personId] = (summary[debt.personId] ?? 0) + debt.amount;
  }
  return summary;
});

final totalDebtByTypeProvider = Provider.family<DebtInfo, DebtType>((ref, type) {
  final debts = ref.watch(debtProvider).value ?? [];
  double totalDebt = 0;
  double totalDebtPaid = 0;
  double totalDebtRemaining = 0;

  for (var debt in debts) {
    if (debt.type == type) {
      totalDebt += debt.amount;
      totalDebtRemaining += debt.remainingAmount;
      totalDebtPaid += debt.paidAmount;
    }
  }
  return DebtInfo(totalDebt: totalDebt, totalDebtPaid: totalDebtPaid, totalDebtRemaining: totalDebtRemaining);
});

// Provider to hold selected debt for repayment/collection
final selectedDebtProvider = StateProvider<Debt?>((ref) => null);

/// Helper function to pay debt by person (auto-distribute across all debts of that person)
/// Returns a void function that can be used with FutureProvider or called directly
void Function() payDebtByPersonFn(
  WidgetRef ref,
  int personId,
  double paymentAmount,
  int walletId,
) {
  return () async {
    await ref.read(debtProvider.notifier).payDebtByPerson(personId, paymentAmount, walletId);
  };
}

/// Helper function to collect debt by person (auto-distribute across all debts of that person)
void Function() collectDebtByPersonFn(
  WidgetRef ref,
  int personId,
  double paymentAmount,
  int walletId,
) {
  return () async {
    await ref.read(debtProvider.notifier).collectDebtByPerson(personId, paymentAmount, walletId);
  };
}
