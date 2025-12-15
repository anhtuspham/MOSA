import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/router/app_routes.dart';
import 'package:mosa/screens/wallet/widgets/account_tab_screen.dart';
import 'package:mosa/screens/wallet/widgets/accumulated_tab_screen.dart';
import 'package:mosa/utils/app_colors.dart';
import 'package:mosa/utils/app_icons.dart';
import 'package:mosa/widgets/custom_list_tile.dart';
import 'package:mosa/widgets/tab_bar_scaffold.dart';

/// Wallet management screen with accounts, savings, and accumulation tabs
class WalletShellScreen extends StatelessWidget {
  const WalletShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TabBarScaffold(
      title: const Text('Tài khoản', style: TextStyle(fontWeight: FontWeight.w500)),
      actions: const [Icon(Icons.search), SizedBox(width: 10), Icon(Icons.sort_rounded)],
      tabs: const [Tab(text: 'Tài khoản'), Tab(text: 'Sổ tiết kiệm'), Tab(text: 'Tích lũy')],
      appBarBackgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addWallet),
        shape: CircleBorder(),
        backgroundColor: AppColors.buttonPrimary,
        foregroundColor: AppColors.textWhite,
        child: Icon(Icons.add),
      ),
      children: [AccountTabScreen(), _buildWalletTab('Sổ tiết kiệm'), AccumulatedTabScreen()],
    );
  }

  /// Build wallet content for each tab
  static Widget _buildWalletTab(String tabTitle) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.secondary),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tổng tiền', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              Text('3.697.530đ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: SingleChildScrollView(
            child: Column(
              children: [
                CustomListTile(
                  leading: Image.asset(AppIcons.logoMbBank, width: 30),
                  title: Text('Mb bank', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  subTitle: Text('913.024đ'),
                  trailing: IconButton(onPressed: null, icon: Icon(Icons.more_vert, color: AppColors.textPrimary)),
                ),
                CustomListTile(
                  leading: Image.asset(AppIcons.logoCash, width: 30),
                  title: Text('Tiền mặt', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  subTitle: Text('913.024đ'),
                  trailing: IconButton(onPressed: null, icon: Icon(Icons.more_vert, color: AppColors.textPrimary)),
                ),
                CustomListTile(
                  leading: Image.asset(AppIcons.logoMomo, width: 30),
                  title: Text('Mb bank', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  subTitle: Text('913.024đ'),
                  trailing: IconButton(onPressed: null, icon: Icon(Icons.more_vert, color: AppColors.textPrimary)),
                ),
                CustomListTile(
                  leading: Image.asset(AppIcons.logoZalopay, width: 30),
                  title: Text('Mb bank', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  subTitle: Text('913.024đ'),
                  trailing: IconButton(onPressed: null, icon: Icon(Icons.more_vert, color: AppColors.textPrimary)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
