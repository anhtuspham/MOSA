import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/router/app_routes.dart';
import 'package:mosa/screens/category/screen/category_screen.dart';
import 'package:mosa/screens/login/login_screen.dart';
import 'package:mosa/screens/setting/setting_screen.dart';
import 'package:mosa/screens/shell_scaffold/shell_scaffold_screen.dart';
import 'package:mosa/screens/stats/screen/stats_screen.dart';
import 'package:mosa/screens/transaction/add_transaction_screen.dart';
import 'package:mosa/screens/wallet/screen/select_transfer_from_wallet_screen.dart';
import 'package:mosa/screens/wallet/screen/select_transfer_to_wallet_screen.dart';
import 'package:mosa/screens/wallet/screen/select_wallet_screen.dart';
import 'package:mosa/screens/wallet/screen/wallet_screen.dart';

import '../screens/home/home_screen.dart';

/// Go Router Configuration with StatefulShellRoute
///
/// Architecture:
/// ├─ StatefulShellRoute (Main Shell)
/// │  ├─ ShellScaffoldScreen (AppBar + BottomNav)
/// │  └─ Branches (5):
/// │     ├─ /overview → HomeScreen (with 3 internal tabs)
/// │     ├─ /wallet → WalletShellScreen
/// │     ├─ /stats → StatsShellScreen
/// │     └─ /settings → SettingsShellScreen
/// │
/// └─ Overlay Routes (on top of shell):
///    ├─ /add-transaction → AddTransactionScreen
///    └─ /edit-transaction/:id → AddTransactionScreen

final goRouter = GoRouter(
  initialLocation: AppRoutes.addTransaction,
  debugLogDiagnostics: true,

  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ShellScaffoldScreen(navigationShell: navigationShell, child: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: AppRoutes.overview, name: 'overview', builder: (context, state) => HomeScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: AppRoutes.wallet, name: 'wallet', builder: (context, state) => WalletShellScreen())],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.addTransaction,
              name: 'add-transaction',
              builder: (context, state) => AddTransactionScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: AppRoutes.stats, name: 'stats', builder: (context, state) => StatsShellScreen())],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: AppRoutes.settings, name: 'setting', builder: (context, state) => SettingsShellScreen()),
          ],
        ),
      ],
    ),

    GoRoute(path: AppRoutes.login, name: 'login', builder: (context, state) => LoginScreen()),
    GoRoute(path: AppRoutes.categoryList, name: 'categoryList', builder: (context, state) => CategoryScreen()),
    GoRoute(path: AppRoutes.selectWallet, name: 'selectWallet', builder: (context, state) => SelectWalletScreen()),
    GoRoute(
      path: AppRoutes.selectTransferOutWallet,
      name: 'selectTransferOutWallet',
      builder: (context, state) => SelectTransferOutWalletScreen(),
    ),
    GoRoute(
      path: AppRoutes.selectTransferInWallet,
      name: 'selectTransferInWallet',
      builder: (context, state) => SelectTransferInWalletScreen(),
    ),
  ],
  errorBuilder: (context, state) {
    return Scaffold(
      appBar: AppBar(title: Text('Lỗi trang')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Router không tồn tại'),
            const SizedBox(height: 12),
            Text('Path: ${state.uri} không tồn tại. Vui lòng kiểm tra lại', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: () => context.go(AppRoutes.overview), child: Text('Quay về trang chủ')),
          ],
        ),
      ),
    );
  },
);
