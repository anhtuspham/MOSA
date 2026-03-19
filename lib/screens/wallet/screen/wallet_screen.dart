import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/router/app_routes.dart';
import 'package:mosa/screens/wallet/widgets/account_tab_screen.dart';
import 'package:mosa/screens/wallet/widgets/accumulated_tab_screen.dart';
import 'package:mosa/config/app_colors.dart';
import 'package:mosa/utils/app_icons.dart';
import 'package:mosa/widgets/custom_list_tile.dart';
import 'package:mosa/widgets/logo_container.dart';
import 'package:mosa/widgets/common_scaffold.dart';

/// Wallet management screen with accounts, savings, and accumulation tabs
class WalletShellScreen extends StatelessWidget {
  const WalletShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonScaffold.tabbed(
      title: const Text('Tài khoản', style: TextStyle(fontWeight: FontWeight.w500)),
      actions: const [Icon(Icons.search), SizedBox(width: 10), Icon(Icons.sort_rounded)],
      tabs: const [Tab(text: 'Tài khoản'), Tab(text: 'Sổ tiết kiệm'), Tab(text: 'Tích lũy')],
      appBarBackgroundColor: Theme.of(context).colorScheme.surface,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addWallet),
        shape: CircleBorder(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: Icon(Icons.add),
      ),
      children: [AccountTabScreen(), _buildWalletTab(context, 'Sổ tiết kiệm'), AccumulatedTabScreen()],
    );
  }

  /// Build wallet content for each tab
  static Widget _buildWalletTab(BuildContext context, String tabTitle) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.onPrimaryFixedVariant),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tổng tiền', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white)),
              Text('3.697.530đ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: SingleChildScrollView(
            child: Column(
              children: [
                CustomListTile(
                  leading: const LogoContainer(assetPath: AppIcons.logoMbBank),
                  title: const Text('Mb bank', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  subTitle: const Text('913.024đ'),
                  trailing: IconButton(
                    onPressed: null,
                    icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurface),
                  ),
                ),
                CustomListTile(
                  leading: const LogoContainer(assetPath: AppIcons.logoCash),
                  title: const Text('Tiền mặt', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  subTitle: const Text('913.024đ'),
                  trailing: IconButton(
                    onPressed: null,
                    icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurface),
                  ),
                ),
                CustomListTile(
                  leading: const LogoContainer(assetPath: AppIcons.logoMomo),
                  title: const Text('Momo', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  subTitle: const Text('913.024đ'),
                  trailing: IconButton(
                    onPressed: null,
                    icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurface),
                  ),
                ),
                CustomListTile(
                  leading: const LogoContainer(assetPath: AppIcons.logoZalopay),
                  title: const Text('Zalopay', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  subTitle: const Text('913.024đ'),
                  trailing: IconButton(
                    onPressed: null,
                    icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurface),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
