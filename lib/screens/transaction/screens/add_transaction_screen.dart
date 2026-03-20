import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mosa/models/debt.dart';
import 'package:mosa/models/enums.dart';
import 'package:mosa/providers/category_provider.dart';
import 'package:mosa/providers/person_provider.dart';
import 'package:mosa/providers/transaction_prefill_data_provider.dart';
import 'package:mosa/providers/transaction_provider.dart';
import 'package:mosa/providers/wallet_provider.dart';
import 'package:mosa/services/transaction_service.dart';
import 'package:mosa/utils/constants.dart';
import 'package:mosa/utils/helpers.dart';
import 'package:mosa/utils/toast.dart';
import 'package:mosa/utils/transaction_constants.dart';
import 'package:mosa/widgets/common_scaffold.dart';
import 'package:mosa/widgets/date_time_selector_section.dart';
import 'package:mosa/widgets/media_action_bar.dart';
import 'package:mosa/widgets/section_container.dart';
import 'package:mosa/widgets/text_selector_section.dart';
import 'package:mosa/widgets/transaction/adjust_balance_section.dart';
import 'package:mosa/widgets/transaction/amount_input_section.dart';
import 'package:mosa/widgets/transaction/category_selector_section.dart';
import 'package:mosa/widgets/transaction/person_selector_section.dart';
import 'package:mosa/widgets/transaction/transaction_type_dropdown.dart';
import 'package:mosa/widgets/transaction/transfer_wallet_section.dart';
import 'package:mosa/widgets/transaction/wallet_selector_section.dart';
import 'package:mosa/widgets/card_section.dart';

/// Màn hình thêm giao dịch mới
class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _actualBalanceController = TextEditingController();
  late DateTime _selectedDateTime = DateTime.now();
  DateTime? _selectedLoanDateTime;

  @override
  void initState() {
    super.initState();
    _initializePrefillData();
  }

  /// Khởi tạo dữ liệu điền trước từ provider
  void _initializePrefillData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeTransactionTypeProvider.notifier).state = TransactionType.expense;
      final prefill = ref.read(transactionPrefillDataProvider);
      if (prefill != null) {
        _applyPrefill(prefill);
        ref.read(transactionPrefillDataProvider.notifier).state = null;
      }
    });
  }

  /// Áp dụng dữ liệu điền trước vào các điều khiển
  void _applyPrefill(TransactionPrefill prefill) {
    if (prefill.amount != null) {
      _amountController.text = Helpers.formatNumber(prefill.amount ?? 0);
    }
    if (prefill.type != null) {
      ref.read(activeTransactionTypeProvider.notifier).state = prefill.type;
    }
    if (prefill.person != null) {
      ref.read(selectedPersonProvider.notifier).state = prefill.person;
    }
    if (prefill.category != null) {
      ref.read(selectedCategoryProvider.notifier).selectCategory(prefill.category);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _actualBalanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _listenToPrefillChanges();
    final selectedTransactionType = ref.watch(activeTransactionTypeProvider) ?? TransactionType.expense;
    return CommonScaffold.single(
      title: _buildAppBarTitle(),
      centerTitle: true,
      leading: const Icon(Icons.history),
      actions: [IconButton(onPressed: _saveTransaction, icon: const Icon(Icons.check))],
      appBarBackgroundColor: Theme.of(context).colorScheme.surface,
      body: SectionContainer(child: _buildTransactionDetail(selectedTransactionType)),
    );
  }

  /// Lắng nghe thay đổi của dữ liệu điền trước
  void _listenToPrefillChanges() {
    ref.listen<TransactionPrefill?>(transactionPrefillDataProvider, (previous, next) {
      if (next != null) {
        _applyPrefill(next);
        Future.microtask(() {
          ref.read(transactionPrefillDataProvider.notifier).state = null;
        });
      }
    });
  }

  /// Xây dựng tiêu đề AppBar với Dropdown loại giao dịch
  Widget _buildAppBarTitle() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      constraints: const BoxConstraints(maxWidth: 180),
      child: TransactionTypeDropdown(onTypeChanged: (_) => _resetForm()),
    );
  }

  /// Đặt lại toàn bộ dữ liệu trong form
  void _resetForm() {
    _noteController.clear();
    _actualBalanceController.clear();
    _selectedDateTime = DateTime.now();
    _selectedLoanDateTime = null;
    ref.read(transactionPrefillDataProvider.notifier).state = TransactionPrefill(
      amount: 0,
      person: null,
      category: null,
    );
  }

  /// Phương thức lưu giao dịch chính
  Future<void> _saveTransaction() async {
    if (!mounted) return;

    try {
      final type = ref.read(activeTransactionTypeProvider) ?? TransactionType.expense;
      final service = ref.read(transactionServiceProvider);

      switch (type) {
        case TransactionType.adjustBalance:
          await _handleSaveAdjustBalance(service);
        case TransactionType.lend:
        case TransactionType.borrowing:
          await _handleSaveLendOrBorrow(service, type);
        case TransactionType.transfer:
          await _handleSaveTransfer(service);
        default:
          await _handleSaveRegularTransaction(service, type);
      }

      _resetForm();
      _notifySuccess();
    } catch (e) {
      log('Lỗi khi lưu giao dịch: $e', name: 'AddTransactionScreen');
      _notifyError(e.toString());
    }
  }

  /// Lưu giao dịch điều chỉnh số dư
  Future<void> _handleSaveAdjustBalance(TransactionService service) async {
    final balanceText = _actualBalanceController.text.replaceAll('.', '');
    final actualBalance = double.tryParse(balanceText) ?? 0.0;
    final wallet = await ref.read(effectiveWalletProvider.future);

    await service.saveAdjustBalanceTransaction(
      actualBalance: actualBalance,
      wallet: wallet,
      date: _selectedDateTime,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
    );
  }

  /// Lưu giao dịch cho vay hoặc đi vay
  Future<void> _handleSaveLendOrBorrow(TransactionService service, TransactionType type) async {
    final person = ref.read(selectedPersonProvider);
    service.validatePerson(person);
    service.validateAmount(_amountController.text);

    final amountText = _amountController.text.replaceAll('.', '');
    final amount = double.tryParse(amountText) ?? 0.0;
    final wallet = await ref.read(effectiveWalletProvider.future);

    await service.saveLendOrBorrowTransaction(
      amount: amount,
      date: _selectedDateTime,
      type: type,
      person: person!, // Đã được validate ở trên
      wallet: wallet,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
      dueDate: _selectedLoanDateTime,
    );
  }

  /// Lưu giao dịch chuyển khoản
  Future<void> _handleSaveTransfer(TransactionService service) async {
    service.validateAmount(_amountController.text);

    final amountText = _amountController.text.replaceAll('.', '');
    final amount = double.tryParse(amountText) ?? 0.0;
    final fromWallet = ref.read(transferOutWalletProvider);
    final toWallet = ref.read(transferInWalletProvider);

    service.validateTransferWallets(fromWallet, toWallet);

    await service.saveTransferTransaction(
      amount: amount,
      date: _selectedDateTime,
      fromWallet: fromWallet!, // Đã được validate
      toWallet: toWallet!, // Đã được validate
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
    );
  }

  /// Lưu giao dịch thu nhập/chi phí thông thường
  Future<void> _handleSaveRegularTransaction(TransactionService service, TransactionType type) async {
    final category = ref.read(selectedCategoryProvider);
    service.validateCategory(category);
    service.validateAmount(_amountController.text);

    final amountText = _amountController.text.replaceAll('.', '');
    final amount = double.tryParse(amountText) ?? 0.0;
    final wallet = await ref.read(effectiveWalletProvider.future);

    if (category?.type == 'lend') {
      await _handleSaveDebtTransaction(service, type, amount, wallet);
    } else {
      await service.saveRegularTransaction(
        amount: amount,
        date: _selectedDateTime,
        type: type,
        category: category!, // Đã được validate
        wallet: wallet,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
      );
    }
  }

  /// Xử lý lưu giao dịch liên quan đến nợ (thu nợ/trả nợ)
  Future<void> _handleSaveDebtTransaction(
    TransactionService service,
    TransactionType type,
    double amount,
    dynamic wallet,
  ) async {
    final person = ref.read(selectedPersonProvider);

    if (type == TransactionType.income) {
      service.validatePersonDebt(person, DebtType.lent);
      await service.saveDebtCollectionTransaction(amount: amount, person: person!, wallet: wallet);
    } else if (type == TransactionType.expense) {
      service.validatePersonDebt(person, DebtType.borrowed);
      await service.saveDebtRepaymentTransaction(amount: amount, person: person!, wallet: wallet);
    }
  }

  void _notifySuccess() {
    if (!mounted) return;
    showResultToast(TransactionConstants.successSaveTransaction);
  }

  void _notifyError(String error) {
    if (!mounted) return;
    showResultToast(error, isError: true);
  }

  /// Phân bổ widget chi tiết dựa trên loại giao dịch
  Widget _buildTransactionDetail(TransactionType type) {
    switch (type) {
      case TransactionType.lend:
      case TransactionType.borrowing:
        return _LoanTransactionBody(
          type: type,
          amountController: _amountController,
          selectedDate: _selectedLoanDateTime,
          onDateChanged: (date) => setState(() => _selectedLoanDateTime = date),
          bottomSection: _buildBottomFormSection(),
          saveButton: _buildSaveButton(),
        );
      case TransactionType.transfer:
        return _TransferTransactionBody(
          amountController: _amountController,
          noteController: _noteController,
          selectedDate: _selectedDateTime,
          onDateChanged: (date) => setState(() => _selectedDateTime = date),
          saveButton: _buildSaveButton(),
        );
      case TransactionType.adjustBalance:
        return _AdjustBalanceBody(
          actualBalanceController: _actualBalanceController,
          noteController: _noteController,
          selectedDate: _selectedDateTime,
          onDateChanged: (date) => setState(() => _selectedDateTime = date),
          saveButton: _buildSaveButton(),
        );
      default:
        return _DefaultTransactionBody(
          type: type,
          amountController: _amountController,
          bottomSection: _buildBottomFormSection(),
          saveButton: _buildSaveButton(),
        );
    }
  }

  Widget _buildBottomFormSection() {
    return _WalletAndDetailSection(
      selectedDateTime: _selectedDateTime,
      noteController: _noteController,
      onDateTimeChanged: (date) => setState(() => _selectedDateTime = date),
    );
  }

  Widget _buildSaveButton() {
    return _SaveButton(onPressed: _saveTransaction);
  }
}

/// Widget cho phần ví và chi tiết (ngày, ghi chú)
class _WalletAndDetailSection extends StatelessWidget {
  final DateTime selectedDateTime;
  final TextEditingController noteController;
  final ValueChanged<DateTime> onDateTimeChanged;

  const _WalletAndDetailSection({
    required this.selectedDateTime,
    required this.noteController,
    required this.onDateTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CardSection(
      child: Column(
        children: [
          const WalletSelectorSection(),
          const SizedBox(height: 8),
          DateTimeSelectorSection(selectedDateTime: selectedDateTime, onDateTimeChanged: onDateTimeChanged),
          TextSelectorSection(
            controller: noteController,
            leading: const Icon(Icons.notes_sharp),
            hintText: TransactionConstants.notes,
          ),
        ],
      ),
    );
  }
}

/// Widget thanh hành động đa phương tiện (ảnh, giọng nói)
class _MediaActionSection extends StatelessWidget {
  const _MediaActionSection();

  @override
  Widget build(BuildContext context) {
    return CardSection(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: MediaActionBar(onMicTap: () {}, onImageTap: () {}, onCameraTap: () {}),
    );
  }
}

/// Nút lưu giao dịch dùng chung
class _SaveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SaveButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(AppConstants.save),
      ),
    );
  }
}

/// Thân màn hình cho giao dịch Cho vay/Đi vay
class _LoanTransactionBody extends StatelessWidget {
  final TransactionType type;
  final TextEditingController amountController;
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateChanged;
  final Widget bottomSection;
  final Widget saveButton;

  const _LoanTransactionBody({
    required this.type,
    required this.amountController,
    required this.selectedDate,
    required this.onDateChanged,
    required this.bottomSection,
    required this.saveButton,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                AmountInputSection(controller: amountController, transactionType: type),
                const SizedBox(height: 12),
                const CategorySelectorSection(),
                const PersonSelectorSection(),
                const SizedBox(height: 12),
                bottomSection,
                DateOnlySelectorSection(
                  selectedDateOnly: selectedDate,
                  onDateTimeChanged: onDateChanged,
                  defaultTitle:
                      type == TransactionType.lend
                          ? TransactionConstants.debtCollectionDate
                          : TransactionConstants.debtRepaymentDate,
                ),
                const SizedBox(height: 12),
                const _MediaActionSection(),
              ],
            ),
          ),
        ),
        saveButton,
      ],
    );
  }
}

/// Thân màn hình cho giao dịch Chuyển khoản
class _TransferTransactionBody extends StatelessWidget {
  final TextEditingController amountController;
  final TextEditingController noteController;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final Widget saveButton;

  const _TransferTransactionBody({
    required this.amountController,
    required this.noteController,
    required this.selectedDate,
    required this.onDateChanged,
    required this.saveButton,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                AmountInputSection(controller: amountController, transactionType: TransactionType.transfer),
                const SizedBox(height: 12),
                TransferWalletSection(title: TransactionConstants.fromAccountLabel, isTransferOut: true),
                TransferWalletSection(title: TransactionConstants.toAccountLabel, isTransferOut: false),
                const SizedBox(height: 12),
                DateTimeSelectorSection(selectedDateTime: selectedDate, onDateTimeChanged: onDateChanged),
                TextSelectorSection(
                  controller: noteController,
                  leading: const Icon(Icons.notes_sharp),
                  hintText: TransactionConstants.notes,
                ),
              ],
            ),
          ),
        ),
        saveButton,
      ],
    );
  }
}

/// Thân màn hình cho giao dịch Điều chỉnh số dư
class _AdjustBalanceBody extends StatelessWidget {
  final TextEditingController actualBalanceController;
  final TextEditingController noteController;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final Widget saveButton;

  const _AdjustBalanceBody({
    required this.actualBalanceController,
    required this.noteController,
    required this.selectedDate,
    required this.onDateChanged,
    required this.saveButton,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const WalletSelectorSection(),
                const SizedBox(height: 12),
                AdjustBalanceSection(actualBalanceController: actualBalanceController),
                const SizedBox(height: 12),
                DateTimeSelectorSection(selectedDateTime: selectedDate, onDateTimeChanged: onDateChanged),
                TextSelectorSection(
                  controller: noteController,
                  leading: const Icon(Icons.notes_sharp),
                  hintText: TransactionConstants.notes,
                ),
              ],
            ),
          ),
        ),
        saveButton,
      ],
    );
  }
}

/// Thân màn hình cho giao dịch Thu nhập/Chi phí thông thường
class _DefaultTransactionBody extends ConsumerWidget {
  final TransactionType type;
  final TextEditingController amountController;
  final Widget bottomSection;
  final Widget saveButton;

  const _DefaultTransactionBody({
    required this.type,
    required this.amountController,
    required this.bottomSection,
    required this.saveButton,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);

    // Kiểm tra nếu là thu nợ/trả nợ (loại đặc biệt của income/expense)
    if (selectedCategory?.type == 'lend') {
      return _LoanTransactionBody(
        type: type,
        amountController: amountController,
        selectedDate: null, // Không cần ngày đến hạn cho trả nợ/thu nợ lẻ
        onDateChanged: (_) {},
        bottomSection: bottomSection,
        saveButton: saveButton,
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                AmountInputSection(controller: amountController, transactionType: type),
                const SizedBox(height: 12),
                const CategorySelectorSection(),
                const SizedBox(height: 12),
                bottomSection,
                const SizedBox(height: 12),
                const _MediaActionSection(),
              ],
            ),
          ),
        ),
        saveButton,
      ],
    );
  }
}
