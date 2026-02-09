import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mosa/models/debt.dart';
import 'package:mosa/models/enums.dart';
import 'package:mosa/models/transaction.dart';
import 'package:mosa/models/category.dart';
import 'package:mosa/models/person.dart';
import 'package:mosa/models/wallets.dart';
import 'package:mosa/providers/debt_provider.dart';
import 'package:mosa/providers/transaction_provider.dart';
import 'package:mosa/utils/utils.dart';

/// Service class to handle transaction business logic
/// Separates business logic from UI layer
class TransactionService {
  final Ref ref;

  TransactionService(this.ref);

  /// Save a regular income or expense transaction
  Future<void> saveRegularTransaction({
    required double amount,
    required DateTime date,
    required TransactionType type,
    required Category category,
    required Wallet wallet,
    String? note,
  }) async {
    final transaction = TransactionModel(
      title: category.name,
      amount: amount,
      date: date,
      type: type,
      categoryId: category.id,
      note: note,
      createAt: DateTime.now(),
      syncId: generateSyncId(),
      walletId: wallet.id ?? -1,
    );

    final transactionController = ref.read(transactionProvider.notifier);
    await transactionController.addTransaction(transaction);
  }

  /// Save a balance adjustment transaction
  Future<void> saveAdjustBalanceTransaction({
    required double actualBalance,
    required Wallet wallet,
    required DateTime date,
    String? note,
  }) async {
    final adjustmentAmount = actualBalance - wallet.balance;

    if (adjustmentAmount == 0) {
      throw Exception('Số dư thực tế giống với số dư hiện tại');
    }

    final transaction = TransactionModel(
      title: 'Điều chỉnh số dư',
      amount: adjustmentAmount,
      date: date,
      type: TransactionType.adjustBalance,
      categoryId: 'adjustment',
      note: note,
      createAt: DateTime.now(),
      syncId: generateSyncId(),
      walletId: wallet.id ?? -1,
    );

    final transactionController = ref.read(transactionProvider.notifier);
    await transactionController.addTransaction(transaction);
  }

  /// Save a lend or borrow transaction (creates a debt)
  Future<void> saveLendOrBorrowTransaction({
    required double amount,
    required DateTime date,
    required TransactionType type,
    required Person person,
    required Wallet wallet,
    String? note,
    DateTime? dueDate,
  }) async {
    if (type != TransactionType.lend && type != TransactionType.borrowing) {
      throw Exception('Invalid transaction type for loan');
    }

    final debt = Debt(
      personId: person.id,
      amount: amount,
      type: type == TransactionType.lend ? DebtType.lent : DebtType.borrowed,
      description: note?.isNotEmpty == true ? note! : 'Giao dịch với ${person.name}',
      createdDate: date,
      walletId: wallet.id ?? -1,
      dueDate: dueDate,
    );

    final debtController = ref.read(debtProvider.notifier);
    await debtController.createDebt(debt);
  }

  /// Save a transfer transaction (creates 2 transactions: out and in)
  Future<void> saveTransferTransaction({
    required double amount,
    required DateTime date,
    required Wallet fromWallet,
    required Wallet toWallet,
    String? note,
  }) async {
    final transactionOut = TransactionModel(
      title: 'Chuyển khoản đến ${toWallet.name}',
      amount: amount,
      date: date,
      type: TransactionType.transferOut,
      categoryId: 'transfer',
      note: note,
      createAt: DateTime.now(),
      syncId: generateSyncId(),
      walletId: fromWallet.id ?? -1,
    );

    final transactionIn = TransactionModel(
      title: 'Nhận chuyển khoản từ ${fromWallet.name}',
      amount: amount,
      date: date,
      type: TransactionType.transferIn,
      categoryId: 'transfer',
      note: note,
      createAt: DateTime.now(),
      syncId: generateSyncId(),
      walletId: toWallet.id ?? -1,
    );

    final transactionController = ref.read(transactionProvider.notifier);
    await transactionController.addTransaction(transactionOut);
    await transactionController.addTransaction(transactionIn);
  }

  /// Save a debt collection transaction (when someone pays you back)
  Future<void> saveDebtCollectionTransaction({
    required double amount,
    required Person person,
    required Wallet wallet,
  }) async {
    final debtController = ref.read(debtProvider.notifier);
    await debtController.collectDebtByPerson(person.id, amount, wallet.id!);
  }

  /// Save a debt repayment transaction (when you pay someone back)
  Future<void> saveDebtRepaymentTransaction({
    required double amount,
    required Person person,
    required Wallet wallet,
  }) async {
    final debtController = ref.read(debtProvider.notifier);
    await debtController.payDebtByPerson(person.id, amount, wallet.id!);
  }

  /// Validate amount input
  void validateAmount(String amountText) {
    if (amountText.isEmpty) {
      throw Exception('Vui lòng nhập số tiền');
    }

    final amount = double.tryParse(amountText.replaceAll('.', ''));
    if (amount == null || amount <= 0) {
      throw Exception('Số tiền không hợp lệ');
    }
  }

  /// Validate category selection
  void validateCategory(Category? category) {
    if (category == null) {
      throw Exception('Vui lòng chọn hạng mục');
    }
  }

  /// Validate person selection
  void validatePerson(Person? person) {
    if (person == null) {
      throw Exception('Vui lòng chọn người');
    }
  }

  /// Validate debt person selection
  void validatePersonDebt(Person? person, DebtType debtType) {
  if (person == null) {
    throw Exception('Vui lòng chọn người');
  }
  
  final summary = ref.read(debtSummaryByTypeProvider(debtType));
  if (!summary.containsKey(person.id)) {
    throw Exception('Người này không có khoản nợ ${debtType == DebtType.lent ? "cần thu" : "cần trả"}');
  }
}

  /// Validate transfer wallets
  void validateTransferWallets(Wallet? fromWallet, Wallet? toWallet) {
    if (fromWallet == null) {
      throw Exception('Vui lòng chọn tài khoản nguồn');
    }
    if (toWallet == null) {
      throw Exception('Vui lòng chọn tài khoản đích');
    }
    if (fromWallet.id == toWallet.id) {
      throw Exception('Không thể chuyển khoản vào cùng một tài khoản');
    }
  }
}

/// Provider for TransactionService
final transactionServiceProvider = Provider<TransactionService>((ref) {
  return TransactionService(ref);
});
