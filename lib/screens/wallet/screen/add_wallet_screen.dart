import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/providers/bank_provider.dart';
import 'package:mosa/providers/wallet_provider.dart';
import 'package:mosa/widgets/date_time_selector_section.dart';
import 'package:mosa/widgets/note_selector_section.dart';
import 'package:mosa/widgets/section_container.dart';
import 'package:mosa/widgets/tab_bar_scaffold.dart';

import '../../../router/app_routes.dart';
import '../../../utils/app_colors.dart';
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

  @override
  void dispose() {
    _amountController.dispose();
    _walletNameController.dispose();
    _noteController.dispose();
    super.dispose();
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
        icon: const Icon(Icons.arrow_back),
      ),
      appBarBackgroundColor: AppColors.primaryBackground,
      actions: const [Icon(Icons.check)],
      body: SectionContainer(
        child: Column(
          children: [
            amountInputSection(),
            const SizedBox(height: 12),
            walletAndDetailSection()
          ],
        ),
      ),
    );
  }

  Widget amountInputSection() {
    return CardSection(
      child: Column(
        children: [
          Text('Số dư ban đầu'),
          AmountTextField(
            controller: _amountController,
            amountColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget walletAndDetailSection() {
    final selectedTypeWallet = ref.watch(selectedTypeWalletProvider);

    return CardSection(
      child: Column(
        children: [
          TextSelectorSection(controller: _walletNameController, leading: Icon(Icons.wallet), hintText: 'Tên tài khoản',),
          const SizedBox(height: 8),
          CustomListTile(
            leading: Icon(Icons.wallet_sharp),
            title: Text((selectedTypeWallet?.name ?? '')),
            enable: true,
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              context.push(AppRoutes.typeWalletList);
            },
          ),
          const SizedBox(height: 8,),
          bankSelectorSection(),
          const SizedBox(height: 8),
          TextSelectorSection(controller: _noteController, leading: Icon(Icons.notes_sharp), hintText: 'Diễn giải',)
        ],
      ),
    );
  }

  Widget bankSelectorSection(){
    final selectedBank = ref.watch(selectedBankProvider);

    return CustomListTile(
      leading: Icon(Icons.wallet_sharp),
      title: Text((selectedBank?.name ?? '')),
      enable: true,
      trailing: Icon(Icons.chevron_right),
      onTap: () {
        context.push(AppRoutes.bankList);
      },
    );
  }
}
