import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/providers/wallet_provider.dart';
import 'package:mosa/utils/constants.dart';
import 'package:mosa/utils/helpers.dart';
import 'package:mosa/widgets/custom_list_tile.dart';
import 'package:mosa/widgets/error_widget.dart';
import 'package:mosa/widgets/loading_widget.dart';
import 'package:mosa/widgets/logo_container.dart';

class SelectWalletScreen extends ConsumerStatefulWidget {
  const SelectWalletScreen({super.key});

  @override
  ConsumerState<SelectWalletScreen> createState() => _SelectWalletScreenState();
}

class _SelectWalletScreenState extends ConsumerState<SelectWalletScreen> {
  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(walletProvider);
    final selectedWallet = ref.watch(selectedWalletProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.selectWallet, style: TextStyle(fontWeight: FontWeight.w600)),
        leading: IconButton(onPressed: () => context.pop(), icon: Icon(Icons.arrow_back)),
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
                leading: LogoContainer(assetPath: wallet.iconPath, size: 25),
                title: Text(wallet.name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                subTitle: Text(Helpers.formatCurrency(wallet.balance)),
                backgroundColor: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3) : null,
                trailing:
                    isSelected ? IconButton(onPressed: null, icon: Icon(Icons.check, color: Theme.of(context).colorScheme.primary)) : null,

                onTap: () {
                  ref.read(selectedWalletProvider.notifier).state = wallet;
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
