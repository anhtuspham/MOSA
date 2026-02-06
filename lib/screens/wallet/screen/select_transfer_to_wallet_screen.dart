import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/providers/wallet_provider.dart';
import 'package:mosa/utils/app_colors.dart';
import 'package:mosa/utils/constants.dart';
import 'package:mosa/utils/helpers.dart';
import 'package:mosa/widgets/custom_list_tile.dart';
import 'package:mosa/widgets/error_widget.dart';
import 'package:mosa/widgets/loading_widget.dart';

class SelectTransferInWalletScreen extends ConsumerStatefulWidget {
  const SelectTransferInWalletScreen({super.key});

  @override
  ConsumerState<SelectTransferInWalletScreen> createState() =>
      _SelectWalletScreenState();
}

class _SelectWalletScreenState
    extends ConsumerState<SelectTransferInWalletScreen> {
  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(walletProvider);
    final selectedWallet = ref.watch(transferInWalletProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConstants.selectWallet,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back),
        ),
        actions: [Icon(Icons.search)],
        elevation: 5,
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      body: wallets.when(
        data: (walletData) {
          return ListView.builder(
            itemCount: walletData.length,
            itemBuilder: (context, index) {
              final wallet = walletData[index];
              final isSelected = selectedWallet?.id == wallet.id;

              return CustomListTile(
                leading: Image.asset(wallet.iconPath, width: 30),
                title: Text(
                  wallet.name,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                subTitle: Text(Helpers.formatCurrency(wallet.balance)),
                backgroundColor:
                    isSelected ? AppColors.lightBackGroundColor : null,
                trailing:
                    isSelected
                        ? IconButton(
                          onPressed: null,
                          icon: Icon(Icons.check, color: AppColors.primary),
                        )
                        : null,

                onTap: () {
                  ref.read(transferInWalletProvider.notifier).state = wallet;
                  log('in wallet: ${wallet.name}');
                  context.pop();
                },
              );
            },
          );
        },
        error: (error, stackTrace) => ErrorSectionWidget(error: error),
        loading: () => LoadingSectionWidget(),
      ),
    );
  }
}
