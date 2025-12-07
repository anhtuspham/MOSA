import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/providers/wallet_provider.dart';
import 'package:mosa/utils/app_colors.dart';
import 'package:mosa/utils/app_icons.dart';
import 'package:mosa/widgets/custom_list_tile.dart';
import 'package:mosa/widgets/error_widget.dart';
import 'package:mosa/widgets/loading_widget.dart';

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
        title: Text('Chọn tài khoản', style: TextStyle(fontWeight: FontWeight.w600)),
        leading: IconButton(onPressed: () => context.pop(), icon: Icon(Icons.arrow_back)),
        actions: [Icon(Icons.search)],
        elevation: 5,
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      body: wallets.when(data: (walletData) {
        return ListView.builder(
        itemCount: walletData.length,
        itemBuilder: (context, index) {
          final wallet = walletData[index];
          final isSelected = selectedWallet?.id == wallet.id;

          return CustomListTile(
            leading: Image.asset(wallet.iconPath, width: 30),
            title: Text(wallet.name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            subTitle: Text(wallet.balance.toString()),
            backgroundColor: isSelected ? AppColors.lightBackGroundColor : null,
            trailing:
                isSelected ? IconButton(onPressed: null, icon: Icon(Icons.check, color: AppColors.primary)) : null,
            enable: true,
            onTap: () {
              ref.read(selectedWalletProvider.notifier).state = wallet;
              context.pop();
            },
          );
        },
      );
      }, error: (error, stackTrace) => ErrorSectionWidget(error: error), loading: () => LoadingSectionWidget(),)
    );
  }
}
