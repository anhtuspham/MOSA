import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mosa/models/enums.dart';
import 'package:mosa/providers/category_provider.dart';
import 'package:mosa/providers/debt_provider.dart';
import 'package:mosa/providers/person_provider.dart';
import 'package:mosa/providers/transaction_provider.dart';
import 'package:mosa/providers/wallet_provider.dart';
import 'package:mosa/services/transaction_service.dart';
import 'package:mosa/utils/app_colors.dart';
import 'package:mosa/utils/constants.dart';
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

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentTransactionByTypeProvider.notifier).state =
          TransactionType.expense;
    });
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
    final selectedTransactionType =
        ref.watch(currentTransactionByTypeProvider) ?? TransactionType.expense;

    return CommonScaffold(
      title: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 2, color: AppColors.lightBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        constraints: const BoxConstraints(maxWidth: 180),
        child: TransactionTypeDropdown(
          onTypeChanged: (_) => _clearTransaction(),
        ),
      ),
      centerTitle: true,
      leading: const Icon(Icons.history),
      actions: [
        IconButton(
          onPressed: _saveTransaction,
          icon: const Icon(Icons.check),
        )
      ],
      appBarBackgroundColor: AppColors.primaryBackground,
      body: SectionContainer(
        child: _buildTransactionDetail(selectedTransactionType),
      ),
    );
  }

  /// Clear all form inputs
  void _clearTransaction() {
    _amountController.clear();
    _noteController.clear();
    _actualBalanceController.clear();
    _selectedLoanDateTime = null;
    ref.read(selectedCategoryProvider.notifier).selectCategory(null);
    ref.read(selectedDebtProvider.notifier).state = null;
    ref.read(selectedPersonProvider.notifier).state = null;
  }

  /// Main save transaction method - delegates to appropriate handler
  Future<void> _saveTransaction() async {
    if (!mounted) return;

    try {
      final selectedTransactionType =
          ref.read(currentTransactionByTypeProvider) ?? TransactionType.expense;
      final transactionService = ref.read(transactionServiceProvider);

      switch (selectedTransactionType) {
        case TransactionType.adjustBalance:
          await _saveAdjustBalance(transactionService);
          break;
        case TransactionType.lend:
        case TransactionType.borrowing:
          await _saveLendOrBorrow(transactionService, selectedTransactionType);
          break;
        case TransactionType.transfer:
          await _saveTransfer(transactionService);
          break;
        default:
          await _saveRegularTransaction(
            transactionService,
            selectedTransactionType,
          );
      }

      _clearTransaction();
      _showSuccessToast();
    } catch (e) {
      log('Error saving transaction: $e');
      _showErrorToast(e.toString());
    }
  }

  /// Save adjust balance transaction
  Future<void> _saveAdjustBalance(TransactionService service) async {
    final actualBalance = double.tryParse(
          _actualBalanceController.text.replaceAll('.', ''),
        ) ??
        0;
    final effectiveWallet = await ref.read(effectiveWalletProvider.future);

    await service.saveAdjustBalanceTransaction(
      actualBalance: actualBalance,
      wallet: effectiveWallet,
      date: _selectedDateTime,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
    );
  }

  /// Save lend or borrow transaction
  Future<void> _saveLendOrBorrow(
    TransactionService service,
    TransactionType type,
  ) async {
    final selectedPerson = ref.read(selectedPersonProvider);
    service.validatePerson(selectedPerson);
    service.validateAmount(_amountController.text);

    final amount = double.parse(_amountController.text.replaceAll('.', ''));
    final effectiveWallet = await ref.read(effectiveWalletProvider.future);

    await service.saveLendOrBorrowTransaction(
      amount: amount,
      date: _selectedDateTime,
      type: type,
      person: selectedPerson!,
      wallet: effectiveWallet,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
      dueDate: _selectedLoanDateTime,
    );
  }

  /// Save transfer transaction
  Future<void> _saveTransfer(TransactionService service) async {
    service.validateAmount(_amountController.text);

    final amount = double.parse(_amountController.text.replaceAll('.', ''));
    final transferOutWallet = ref.read(transferOutWalletProvider);
    final transferInWallet = ref.read(transferInWalletProvider);

    service.validateTransferWallets(transferOutWallet, transferInWallet);

    await service.saveTransferTransaction(
      amount: amount,
      date: _selectedDateTime,
      fromWallet: transferOutWallet!,
      toWallet: transferInWallet!,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
    );
  }

  /// Save regular income/expense transaction or debt collection/repayment
  Future<void> _saveRegularTransaction(
    TransactionService service,
    TransactionType type,
  ) async {
    final selectedCategory = ref.read(selectedCategoryProvider);
    service.validateCategory(selectedCategory);
    service.validateAmount(_amountController.text);

    final amount = double.parse(_amountController.text.replaceAll('.', ''));
    final effectiveWallet = await ref.read(effectiveWalletProvider.future);

    // Check if this is a debt collection or repayment
    if (selectedCategory!.type == 'lend') {
      await _saveDebtCollectionOrRepayment(
        service,
        type,
        amount,
        effectiveWallet,
      );
    } else {
      // Regular transaction
      await service.saveRegularTransaction(
        amount: amount,
        date: _selectedDateTime,
        type: type,
        category: selectedCategory,
        wallet: effectiveWallet,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
      );
    }
  }

  /// Save debt collection or repayment
  Future<void> _saveDebtCollectionOrRepayment(
    TransactionService service,
    TransactionType type,
    double amount,
    dynamic wallet,
  ) async {
    final selectedPerson = ref.read(selectedPersonProvider);
    final selectedDebt = ref.read(selectedDebtProvider);

    service.validatePerson(selectedPerson);
    service.validateDebt(selectedDebt);

    if (type == TransactionType.income) {
      // Debt collection
      await service.saveDebtCollectionTransaction(
        amount: amount,
        person: selectedPerson!,
        wallet: wallet,
        debt: selectedDebt!,
      );
    } else if (type == TransactionType.expense) {
      // Debt repayment
      await service.saveDebtRepaymentTransaction(
        amount: amount,
        person: selectedPerson!,
        wallet: wallet,
        debt: selectedDebt!,
      );
    }
  }

  /// Show success toast
  void _showSuccessToast() {
    if (!mounted) return;
    showResultToast(TransactionConstants.successSaveTransaction);
  }

  /// Show error toast
  void _showErrorToast(String error) {
    if (!mounted) return;
    showResultToast(error, isError: true);
  }

  /// Build transaction detail based on type
  Widget _buildTransactionDetail(TransactionType transactionType) {
    switch (transactionType) {
      case TransactionType.lend:
      case TransactionType.borrowing:
        return _buildLoanTransactionDetail(
          transactionType: transactionType,
        );
      case TransactionType.transfer:
        return _buildTransferDetail();
      case TransactionType.adjustBalance:
        return _buildAdjustBalanceDetail();
      default:
        return _buildDefaultTransactionDetail(transactionType);
    }
  }

  /// Build loan transaction detail (lend/borrow)
  Widget _buildLoanTransactionDetail({
    required TransactionType? transactionType,
    bool isRepaymentOrCollection = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                AmountInputSection(
                  controller: _amountController,
                  transactionType: transactionType,
                ),
                const SizedBox(height: 12),
                const CategorySelectorSection(),
                const PersonSelectorSection(),
                const SizedBox(height: 12),
                _buildWalletAndDetailSection(),
                if (!isRepaymentOrCollection)
                  DateOnlySelectorSection(
                    selectedDateOnly: _selectedLoanDateTime,
                    onDateTimeChanged: (newDateTime) {
                      setState(() {
                        _selectedLoanDateTime = newDateTime;
                      });
                    },
                    defaultTitle: transactionType == TransactionType.lend
                        ? TransactionConstants.debtCollectionDate
                        : TransactionConstants.debtRepaymentDate,
                  ),
                const SizedBox(height: 12),
                _buildMediaActionSection(),
              ],
            ),
          ),
        ),
        _buildSaveButton(),
      ],
    );
  }

  /// Build transfer detail
  Widget _buildTransferDetail() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                AmountInputSection(
                  controller: _amountController,
                  transactionType: TransactionType.transfer,
                ),
                const SizedBox(height: 12),
                TransferWalletSection(
                  title: TransactionConstants.fromAccountLabel,
                  isTransferOut: true,
                ),
                TransferWalletSection(
                  title: TransactionConstants.toAccountLabel,
                  isTransferOut: false,
                ),
                const SizedBox(height: 12),
                DateTimeSelectorSection(
                  selectedDateTime: _selectedDateTime,
                  onDateTimeChanged: (newDateTime) {
                    setState(() {
                      _selectedDateTime = newDateTime;
                    });
                  },
                ),
                TextSelectorSection(
                  controller: _noteController,
                  leading: const Icon(Icons.notes_sharp),
                  hintText: TransactionConstants.notes,
                ),
              ],
            ),
          ),
        ),
        _buildSaveButton(),
      ],
    );
  }

  /// Build adjust balance detail
  Widget _buildAdjustBalanceDetail() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const WalletSelectorSection(),
                const SizedBox(height: 12),
                AdjustBalanceSection(
                  actualBalanceController: _actualBalanceController,
                ),
                const SizedBox(height: 12),
                DateTimeSelectorSection(
                  selectedDateTime: _selectedDateTime,
                  onDateTimeChanged: (newDateTime) {
                    setState(() {
                      _selectedDateTime = newDateTime;
                    });
                  },
                ),
                TextSelectorSection(
                  controller: _noteController,
                  leading: const Icon(Icons.notes_sharp),
                  hintText: TransactionConstants.notes,
                ),
              ],
            ),
          ),
        ),
        _buildSaveButton(),
      ],
    );
  }

  /// Build default transaction detail (income/expense)
  Widget _buildDefaultTransactionDetail(TransactionType transactionType) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    
    // Check if this is debt collection or repayment
    if (selectedCategory != null && selectedCategory.type == 'lend') {
      return _buildLoanTransactionDetail(
        transactionType: transactionType,
        isRepaymentOrCollection: true,
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                AmountInputSection(
                  controller: _amountController,
                  transactionType: transactionType,
                ),
                const SizedBox(height: 12),
                const CategorySelectorSection(),
                const SizedBox(height: 12),
                _buildWalletAndDetailSection(),
                const SizedBox(height: 12),
                _buildMediaActionSection(),
              ],
            ),
          ),
        ),
        _buildSaveButton(),
      ],
    );
  }

  /// Build wallet and detail section
  Widget _buildWalletAndDetailSection() {
    return CardSection(
      child: Column(
        children: [
          const WalletSelectorSection(),
          const SizedBox(height: 8),
          DateTimeSelectorSection(
            selectedDateTime: _selectedDateTime,
            onDateTimeChanged: (newDateTime) {
              setState(() {
                _selectedDateTime = newDateTime;
              });
            },
          ),
          TextSelectorSection(
            controller: _noteController,
            leading: const Icon(Icons.notes_sharp),
            hintText: TransactionConstants.notes,
          ),
        ],
      ),
    );
  }

  /// Build media action section
  Widget _buildMediaActionSection() {
    return CardSection(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: MediaActionBar(
        onMicTap: () {
          // TODO: Implement voice recording
        },
        onImageTap: () {
          // TODO: Implement image selection
        },
        onCameraTap: () {
          // TODO: Implement camera capture
        },
      ),
    );
  }

  /// Build save button
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(AppConstants.save),
      ),
    );
  }
}
