import 'package:flutter/material.dart';
import 'package:mosa/utils/app_colors.dart';
import 'package:mosa/widgets/tabBar_scaffold.dart';

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
      children: [_buildWalletTab('Tài khoản'), _buildWalletTab('Sổ tiết kiệm'), _buildWalletTab('Tích lũy')],
    );
  }

  /// Build wallet content for each tab
  static Widget _buildWalletTab(String tabTitle) {
    return Center(child: Text(tabTitle));
  }
}
