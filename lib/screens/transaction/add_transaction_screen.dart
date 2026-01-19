import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/models/category.dart';
import 'package:mosa/models/debt.dart';
import 'package:mosa/models/enums.dart';
import 'package:mosa/models/transaction.dart';
import 'package:mosa/providers/category_provider.dart';
import 'package:mosa/providers/debt_provider.dart';
import 'package:mosa/providers/transaction_provider.dart';
import 'package:mosa/providers/wallet_provider.dart';
import 'package:mosa/router/app_routes.dart';
import 'package:mosa/utils/app_icons.dart';
import 'package:mosa/utils/constants.dart';
import 'package:mosa/widgets/custom_list_tile.dart';
import 'package:mosa/widgets/date_time_selector_section.dart';
import 'package:mosa/widgets/error_widget.dart';
import 'package:mosa/widgets/loading_widget.dart';
import 'package:mosa/widgets/section_container.dart';
import 'package:mosa/widgets/card_section.dart';
import 'package:mosa/widgets/amount_text_field.dart';
import 'package:mosa/widgets/media_action_bar.dart';
import 'package:mosa/widgets/tab_bar_scaffold.dart';
import 'package:toastification/toastification.dart';

import '../../providers/bank_provider.dart';
import '../../providers/person_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/helpers.dart';
import '../../utils/number_input_formatter.dart';
import '../../utils/utils.dart';
import '../../widgets/text_selector_section.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  late final ValueNotifier<TransactionType> _selectedType = ValueNotifier<TransactionType>(TransactionType.expense);
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _actualBalanceController = TextEditingController();
  late DateTime _selectedDateTime = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _actualBalanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: Container(
        decoration: BoxDecoration(border: Border.all(width: 2, color: AppColors.lightBorder), borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.center,
        constraints: BoxConstraints(maxWidth: 180),
        child: transactionTypeDropdown(),
      ),
      centerTitle: true,
      leading: Icon(Icons.history),
      actions: [IconButton(onPressed: _saveTransaction, icon: Icon(Icons.check))],
      appBarBackgroundColor: AppColors.primaryBackground,
      body: SectionContainer(
        child: ValueListenableBuilder(
          valueListenable: _selectedType,
          builder: (context, value, child) => detailTransactionSection(transactionType: _selectedType.value),
        ),
      ),
    );
  }

  void _clearTransaction() async {
    _amountController.clear();
    _noteController.clear();
    _actualBalanceController.clear();
    ref.read(selectedCategoryProvider.notifier).selectCategory(null);
  }

  Future<void> _saveTransaction() async {
    try {
      final selectedCategory = ref.read(selectedCategoryProvider);
      final transactionController = ref.read(transactionProvider.notifier);
      final debtController = ref.read(debtProvider.notifier);
      final effectiveWallet = await ref.read(effectiveWalletProvider.future);
      final transferOutWalletState = ref.watch(transferOutWalletProvider);
      final transferInWalletState = ref.watch(transferInWalletProvider);

      if (!mounted) return;

      if (_selectedType.value == TransactionType.adjustBalance) {
        // For balance adjustment, calculate the difference between actual and current balance
        final actualBalance = double.tryParse(_actualBalanceController.text.replaceAll('.', '')) ?? 0;
        final adjustmentAmount = actualBalance - effectiveWallet.balance;

        if (adjustmentAmount == 0) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Số dư thực tế giống với số dư hiện tại')));
          return;
        }

        final transaction = TransactionModel(
          title: 'Điều chỉnh số dư',
          amount: adjustmentAmount,
          date: _selectedDateTime,
          type: _selectedType.value,
          categoryId: 'adjustment',
          note: _noteController.text.isNotEmpty ? _noteController.text : null,
          createAt: DateTime.now(),
          syncId: generateSyncId(),
          walletId: effectiveWallet.id ?? -1,
        );

        await transactionController.addTransaction(transaction);
      } else {
        // Validation
        if (_amountController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Vui lòng nhập số tiền')));
          return;
        }

        final amount = double.tryParse(_amountController.text.replaceAll('.', ''));
        if (amount == null || amount <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Số tiền không hợp lệ')));
          return;
        }

        if (_selectedType.value == TransactionType.transfer) {
          final transactionOut = TransactionModel(
            title: 'Chuyển khoản đến ${transferInWalletState?.name ?? 'Chưa chọn'}',
            // sử dụng transferIn để gửi title
            // nơi chuyển đến
            amount: amount,
            date: _selectedDateTime,
            type: TransactionType.transferOut,
            categoryId: 'transfer',
            note: _noteController.text.isNotEmpty ? _noteController.text : null,
            createAt: DateTime.now(),
            syncId: generateSyncId(),
            walletId: transferOutWalletState?.id ?? -1,
          );

          final transactionIn = TransactionModel(
            title: 'Nhận chuyển khoản từ ${transferOutWalletState?.name ?? 'Chưa chọn'}',
            amount: amount,
            date: _selectedDateTime,
            type: TransactionType.transferIn,
            categoryId: 'transfer',
            note: _noteController.text.isNotEmpty ? _noteController.text : null,
            createAt: DateTime.now(),
            syncId: generateSyncId(),
            walletId: transferInWalletState?.id ?? -1,
          );

          await transactionController.addTransaction(transactionOut);
          await transactionController.addTransaction(transactionIn);
        } else if (_selectedType.value == TransactionType.lend || _selectedType.value == TransactionType.borrowing) {
          // Validate person selection
          final selectedPerson = ref.read(selectedPersonProvider);
          if (selectedPerson == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Vui lòng chọn người')),
            );
            return;
          }

          Debt debt = Debt(
            personId: selectedPerson.id,
            amount: amount,
            type: _selectedType.value == TransactionType.lend ? DebtType.lent : DebtType.borrowed,
            description: _noteController.text.isNotEmpty
                ? _noteController.text
                : 'Giao dịch với ${selectedPerson.name}',
            createdDate: _selectedDateTime,
            walletId: effectiveWallet.id ?? -1,
          );
          await debtController.createDebt(debt);
        } else {
          if (selectedCategory == null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Vui lòng chọn hạng mục')));
            return;
          }

          final transaction = TransactionModel(
            title: selectedCategory.name,
            amount: amount,
            date: _selectedDateTime,
            type: _selectedType.value,
            categoryId: selectedCategory.id,
            note: _noteController.text.isNotEmpty ? _noteController.text : null,
            createAt: DateTime.now(),
            syncId: generateSyncId(),
            walletId: effectiveWallet.id ?? -1,
          );

          await transactionController.addTransaction(transaction);
        }
      }
      _clearTransaction();

      if (mounted) {
        toastification.show(
          type: ToastificationType.success,
          style: ToastificationStyle.fillColored,
          title: Text('Thành công', style: TextStyle(fontWeight: FontWeight.w600)),
          description: Text('Đã lưu giao dịch', style: TextStyle(fontWeight: FontWeight.w600)),
          alignment: Alignment.topCenter,
          autoCloseDuration: Duration(seconds: 3),
        );
      }
    } catch (e) {
      log('Error saving transaction: $e');
      if (mounted) {
        toastification.show(
          type: ToastificationType.error,
          style: ToastificationStyle.flatColored,
          title: Text('Thất bại', style: TextStyle(fontWeight: FontWeight.w600)),
          description: Text('Lỗi khi lưu giao dịch', style: TextStyle(fontWeight: FontWeight.w600)),
          alignment: Alignment.topCenter,
          autoCloseDuration: Duration(seconds: 3),
        );
      }
    }
  }

  Widget detailTransactionSection({TransactionType transactionType = TransactionType.expense}) {
    switch (transactionType) {
      case TransactionType.transfer:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    amountInputSection(),
                    const SizedBox(height: 12),
                    transactionTypeSection(title: 'Từ tài khoản', isTransferOut: true),
                    transactionTypeSection(title: 'Đến tài khoản', isTransferOut: false),
                    const SizedBox(height: 12),
                    DateTimeSelectorSection(
                      selectedDateTime: _selectedDateTime,
                      onDateTimeChanged: (newDateTime) {
                        setState(() {
                          _selectedDateTime = newDateTime;
                        });
                      },
                    ),
                    TextSelectorSection(controller: _noteController, leading: Icon(Icons.notes_sharp), hintText: 'Diễn giải'),
                  ],
                ),
              ),
            ),
            saveButtonSection(),
          ],
        );
      case TransactionType.adjustBalance:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    walletSelectorSection(),
                    const SizedBox(height: 12),
                    adjustTransactionBalanceSection(),
                    const SizedBox(height: 12),
                    DateTimeSelectorSection(
                      selectedDateTime: _selectedDateTime,
                      onDateTimeChanged: (newDateTime) {
                        setState(() {
                          _selectedDateTime = newDateTime;
                        });
                      },
                    ),
                    TextSelectorSection(controller: _noteController, leading: Icon(Icons.notes_sharp), hintText: 'Diễn giải'),
                  ],
                ),
              ),
            ),
            saveButtonSection(),
          ],
        );
      case TransactionType.lend:
        final lendCategory = ref.watch(categoryByNameProvider('Cho vay')).value;
        if (lendCategory != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(selectedCategoryProvider.notifier).selectCategory(lendCategory);
          });
        }
        return loanTransactionDetail();
      case TransactionType.borrowing:
        final borrowCategory = ref.watch(categoryByNameProvider('Mượn')).value;
        if (borrowCategory != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(selectedCategoryProvider.notifier).selectCategory(borrowCategory);
          });
        }
        return loanTransactionDetail();
      default:
        return defaultTransactionDetail();
    }
  }

  Widget transactionTypeDropdown() {
    return DropdownButtonFormField(
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.never,
        floatingLabelAlignment: FloatingLabelAlignment.center,
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        border: OutlineInputBorder(borderSide: BorderSide.none),
      ),
      isExpanded: true,
      alignment: Alignment.center,
      initialValue: _selectedType.value,
      items: [
        DropdownMenuItem(value: TransactionType.expense, child: Text('Chi tiền')),
        DropdownMenuItem(value: TransactionType.income, child: Text('Thu tiền')),
        DropdownMenuItem(value: TransactionType.lend, child: Text('Cho vay')),
        DropdownMenuItem(value: TransactionType.borrowing, child: Text('Đi vay')),
        DropdownMenuItem(value: TransactionType.transfer, child: Text('Chuyển khoản')),
        DropdownMenuItem(value: TransactionType.adjustBalance, child: Text('Điều chỉnh số dư')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedType.value = value;
            ref.read(currentTransactionByTypeProvider.notifier).state = _selectedType.value;
            _clearTransaction();
          });
        }
      },
    );
  }

  Widget amountInputSection() {
    return CardSection(
      child: Column(
        children: [
          Text('Số tiền'),
          AmountTextField(controller: _amountController, amountColor: getTransactionTypeColor(type: _selectedType.value)),
        ],
      ),
    );
  }

  Widget adjustTransactionBalanceSection() {
    final effectiveWallet = ref.watch(effectiveWalletProvider);
    return effectiveWallet.when(
      data: (wallet) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _actualBalanceController.text = Helpers.formatNumber(wallet.balance);
        });

        return CardSection(
          child: Column(
            children: [
              CustomListTile(title: Text('Số dư trên tài khoản'), trailing: Text(Helpers.formatCurrency(wallet.balance))),
              const SizedBox(height: 12),
              CustomListTile(
                title: Text('Số dư thực tế'),
                trailing: SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _actualBalanceController,
                    decoration: InputDecoration(
                      counterText: '',
                      border: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.borderLight)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      hintText: 'Nhập số dư thực tế',
                      hintStyle: TextStyle(fontSize: 12, color: AppColors.textHint),
                      suffix: Text('đ', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                    maxLength: 16,
                    textAlign: TextAlign.right,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [ThousandSeparatorFormatter(separator: '.')],
                  ),
                ),
              ),
              ValueListenableBuilder(
                valueListenable: _actualBalanceController,
                builder: (context, value, child) {
                  final actualBalance = double.tryParse(_actualBalanceController.text.replaceAll('.', '')) ?? 0;
                  final different = actualBalance - wallet.balance;
                  return CustomListTile(
                    title: Text(different > 0 ? 'Đã thu' : 'Đã chi'),
                    trailing: Text(
                      Helpers.formatCurrency(different),
                      style: TextStyle(color: different > 0 ? AppColors.income : AppColors.expense, fontSize: 18),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
      error: (error, stackTrace) => ErrorSectionWidget(error: error),
      loading: () => LoadingSectionWidget(),
    );
  }

  Widget categorySelectorSection() {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    return CardSection(
      child: Column(
        children: [
          CustomListTile(
            leading: selectedCategory != null ? selectedCategory.getIcon() : Icon(Icons.add_circle_rounded),
            title: Text(selectedCategory != null ? (selectedCategory.name) : 'Chọn hạng mục'),
            enable: true,
            trailing: Row(children: [Text('Tất cả'), const SizedBox(width: 12), Icon(Icons.chevron_right)]),
            onTap: () {
              context.push(AppRoutes.categoryList);
            },
          ),
        ],
      ),
    );
  }

  Widget walletSelectorSection() {
    final effectiveWallet = ref.watch(effectiveWalletProvider);
    return effectiveWallet.when(
      data: (walletData) {
        return CustomListTile(
          leading: Image.asset(walletData.iconPath, width: 22),
          title: Text(walletData.name),
          trailing: Icon(Icons.chevron_right),
          enable: true,
          onTap: () {
            context.push(AppRoutes.selectWallet);
          },
        );
      },
      error: (error, stackTrace) => ErrorSectionWidget(error: error),
      loading: () => LoadingSectionWidget(),
    );
  }

  Widget personLoanSelectorSection() {
    final selectedPerson = ref.watch(selectedPersonProvider);

    return CustomListTile(
      leading: selectedPerson != null
          ? Image.asset(
              selectedPerson.iconPath ?? 'assets/images/icon.png',
              width: 22,
              errorBuilder: (_, __, ___) => Icon(Icons.person, size: 22),
            )
          : Icon(Icons.person_add_outlined),
      title: Text(selectedPerson?.name ?? 'Chọn người'),
      enable: true,
      trailing: Icon(Icons.chevron_right),
      onTap: () {
        context.push(AppRoutes.personList);
      },
    );
  }

  Widget walletAndDetailSection() {
    return CardSection(
      child: Column(
        children: [
          walletSelectorSection(),
          const SizedBox(height: 8),
          DateTimeSelectorSection(
            selectedDateTime: _selectedDateTime,
            onDateTimeChanged: (newDateTime) {
              setState(() {
                _selectedDateTime = newDateTime;
              });
            },
          ),
          TextSelectorSection(controller: _noteController, leading: Icon(Icons.notes_sharp), hintText: 'Diễn giải'),
        ],
      ),
    );
  }

  Widget mediaActionSection() {
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

  Widget transactionTypeSection({String? title, bool isTransferOut = false}) {
    final wallet = isTransferOut ? ref.watch(transferOutWalletProvider) : ref.watch(transferInWalletProvider);
    final route = isTransferOut ? AppRoutes.selectTransferOutWallet : AppRoutes.selectTransferInWallet;

    return CardSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: Text(title, style: TextStyle(color: AppColors.textSecondary)),
            ),
          CustomListTile(
            leading: Image.asset(wallet?.iconPath ?? AppIcons.plusIcon, width: 22),
            title: Text(wallet?.name ?? 'Chọn tài khoản'),
            trailing: Icon(Icons.chevron_right),
            enable: true,
            onTap: () => context.push(route),
          ),
        ],
      ),
    );
  }

  Widget saveButtonSection() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(AppConstants.save),
      ),
    );
  }

  Widget loanTransactionDetail() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                amountInputSection(),
                const SizedBox(height: 12),
                categorySelectorSection(),
                personLoanSelectorSection(),
                const SizedBox(height: 12),
                walletAndDetailSection(),
                const SizedBox(height: 12),
                mediaActionSection(),
              ],
            ),
          ),
        ),
        saveButtonSection(),
      ],
    );
  }

  Widget defaultTransactionDetail() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                amountInputSection(),
                const SizedBox(height: 12),
                categorySelectorSection(),
                const SizedBox(height: 12),
                walletAndDetailSection(),
                const SizedBox(height: 12),
                mediaActionSection(),
              ],
            ),
          ),
        ),
        saveButtonSection(),
      ],
    );
  }
}
