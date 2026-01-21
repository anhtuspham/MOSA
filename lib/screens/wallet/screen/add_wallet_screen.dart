import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/providers/bank_provider.dart';
import 'package:mosa/providers/wallet_provider.dart';
import 'package:mosa/utils/app_icons.dart';
import 'package:mosa/utils/toast.dart';
import 'package:mosa/widgets/text_selector_section.dart';
import 'package:mosa/widgets/section_container.dart';
import 'package:mosa/widgets/tab_bar_scaffold.dart';

import '../../../models/wallets.dart';
import '../../../router/app_routes.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/utils.dart';
import '../../../widgets/amount_text_field.dart';
import '../../../widgets/card_section.dart';
import '../../../widgets/custom_list_tile.dart';

class AddWalletScreen extends ConsumerStatefulWidget {
  const AddWalletScreen({super.key});

  @override
  ConsumerState<AddWalletScreen> createState() => _AddWalletScreenState();
}

class _AddWalletScreenState extends ConsumerState<AddWalletScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _walletNameController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String? iconWalletPath;

  @override
  void dispose() {
    _amountController.dispose();
    _walletNameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    try {
      final walletController = ref.read(walletProvider.notifier);
      final selectTypeWalletController = ref.read(selectedTypeWalletProvider);
      final selectedBankController = ref.watch(selectedBankProvider);

      if (_walletNameController.text.isEmpty) {
        showResultToast('Vui lòng nhập tên ví', isError: true);
        return;
      }

      final newWallet = Wallet(
        id: generateId(),
        name: _walletNameController.text,
        initialBalance: double.tryParse(_amountController.text.replaceAll('.', '')) ?? 0,
        balance: 0,
        note: _noteController.text,
        typeWalletId: selectTypeWalletController?.id ?? 99,
        createAt: DateTime.now(),
        isSynced: false,
        syncId: '',
        iconPath: selectedBankController?.iconPath ?? AppIcons.moneyBag,
        isActive: true,
        bankId: selectedBankController?.id,
      );

      await walletController.insertWallet(newWallet);

      showResultToast('Thêm ví thành công');
      clearInput();
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      showResultToast(e.toString(), isError: true);
    }
  }

  void clearInput() {
    _amountController.clear();
    _walletNameController.clear();
    _noteController.clear();
    ref.read(selectedTypeWalletProvider.notifier).state = null;
    ref.read(selectedBankProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: Text('Thêm tài khoản'),
      centerTitle: true,
      leading: IconButton(
        onPressed: () {
          context.pop();
        },
        icon: Icon(Icons.arrow_back),
      ),
      appBarBackgroundColor: AppColors.primaryBackground,
      actions: [
        IconButton(onPressed: _submit, icon: Icon(Icons.check),)
      ],
      body: SectionContainer(child: Column(children: [amountInputSection(), const SizedBox(height: 12), walletAndDetailSection()])),
    );
  }

  Widget amountInputSection() {
    return CardSection(
      child: Column(children: [Text('Số dư ban đầu'), AmountTextField(controller: _amountController, amountColor: AppColors.primary)]),
    );
  }

  Widget walletAndDetailSection() {
    final selectedTypeWallet = ref.watch(selectedTypeWalletProvider);

    return CardSection(
      child: Column(
        children: [
          TextSelectorSection(controller: _walletNameController, leading: Icon(Icons.wallet), hintText: 'Tên tài khoản'),
          const SizedBox(height: 8),
          CustomListTile(
            leading: selectedTypeWallet != null ? Image.asset(selectedTypeWallet.iconPath ?? '', width: 22) : Icon(Icons.wallet_sharp),
            title: Text((selectedTypeWallet?.name ?? '')),

            trailing: Icon(Icons.chevron_right),
            onTap: () {
              context.push(AppRoutes.typeWalletList);
            },
          ),
          const SizedBox(height: 8),
          if (selectedTypeWallet?.id == 2) ...[bankSelectorSection(), const SizedBox(height: 8)],
          TextSelectorSection(controller: _noteController, leading: Icon(Icons.notes_sharp), hintText: 'Diễn giải'),
        ],
      ),
    );
  }

  Widget bankSelectorSection() {
    final selectedBank = ref.watch(selectedBankProvider);

    return CustomListTile(
      leading: selectedBank != null ? Image.asset(selectedBank.iconPath, width: 22) : Icon(Icons.add_circle_sharp),
      title: Text((selectedBank?.name ?? 'Chọn ngân hàng')),

      trailing: Icon(Icons.chevron_right),
      onTap: () {
        context.push(AppRoutes.bankList);
      },
    );
  }
}
