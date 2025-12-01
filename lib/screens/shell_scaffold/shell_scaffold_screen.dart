import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/providers/transaction_provider.dart';
import 'package:mosa/router/app_routes.dart';

class ShellScaffoldScreen extends ConsumerStatefulWidget {
  final Widget child;
  final StatefulNavigationShell navigationShell;

  const ShellScaffoldScreen({super.key, required this.child, required this.navigationShell});

  @override
  ConsumerState<ShellScaffoldScreen> createState() => _ShellScaffoldScreenState();
}

class _ShellScaffoldScreenState extends ConsumerState<ShellScaffoldScreen> {

  int _getSelectedIndex(){
    final location = GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;

    if(location.contains(AppRoutes.overview)) return 0;
    if(location.contains(AppRoutes.wallet)) return 1;
    if(location.contains(AppRoutes.addTransaction)) return 2;
    if(location.contains(AppRoutes.stats)) return 3;
    if(location.contains(AppRoutes.settings)) return 4;
    return 0;
  }

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.overview);
        break;
      case 1:
        context.go(AppRoutes.wallet);
        break;
      case 2:
        context.go(AppRoutes.addTransaction);
        break;
      case 3:
        context.go(AppRoutes.stats);
        break;
      case 4:
        context.go(AppRoutes.settings);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _getSelectedIndex(),
        onDestinationSelected: _onNavTap,
        destinations: [
          NavigationDestination(icon: Icon(Icons.home_filled), label: 'Tổng quan'),
          NavigationDestination(icon: Icon(Icons.wallet), label: 'Tài khoản'),
          NavigationDestination(icon: Icon(Icons.add_circle_outlined), label: 'Ghi chép'),
          NavigationDestination(icon: Icon(Icons.analytics), label: 'Báo cáo'),
          NavigationDestination(icon: Icon(Icons.widgets_outlined), label: 'Cài đặt'),
        ],
      ),
    );
  }
}
