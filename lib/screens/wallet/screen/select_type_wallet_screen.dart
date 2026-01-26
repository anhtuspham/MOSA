import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/providers/bank_provider.dart';
import 'package:mosa/providers/wallet_provider.dart';
import 'package:mosa/widgets/custom_list_tile.dart';
import 'package:mosa/widgets/error_widget.dart';
import 'package:mosa/widgets/loading_widget.dart';
import 'package:mosa/widgets/common_scaffold.dart';

import '../../../utils/app_colors.dart';

class SelectTypeWalletScreen extends ConsumerStatefulWidget {
  const SelectTypeWalletScreen({super.key});

  @override
  ConsumerState<SelectTypeWalletScreen> createState() => _TypeWalletScreenState();
}

class _TypeWalletScreenState extends ConsumerState<SelectTypeWalletScreen> {
  @override
  Widget build(BuildContext context) {
    final typeWalletState = ref.watch(typeWalletProvider);
    final selectTypeWalletState = ref.watch(selectedTypeWalletProvider);

    return CommonScaffold(
      title: Text('Loại tài khoản'),
      leading: IconButton(
        onPressed: () {
          context.pop();
        },
        icon: const Icon(Icons.arrow_back),
      ),
      body: typeWalletState.when(
        data: (typeWallets) {
          return ListView.builder(
            itemCount: typeWallets.length,
            itemBuilder: (context, index) {
              final typeWallet = typeWallets[index];
              final isSelected = selectTypeWalletState?.id == typeWallet.id;
              return CustomListTile(
                title: Text(typeWallet.name ?? ''),
                leading: Image.asset(typeWallet.iconPath ?? '', width: 30),
                backgroundColor: isSelected ? AppColors.lightBackGroundColor : null,
                trailing: isSelected ? IconButton(onPressed: null, icon: Icon(Icons.check, color: AppColors.primary)) : null,

                onTap: () {
                  ref.read(selectedTypeWalletProvider.notifier).state = typeWallet;
                  ref.read(selectedBankProvider.notifier).state = null;
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
