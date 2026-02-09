import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ShellScaffoldScreen extends ConsumerStatefulWidget {
  final Widget child;
  final StatefulNavigationShell navigationShell;

  const ShellScaffoldScreen({super.key, required this.child, required this.navigationShell});

  @override
  ConsumerState<ShellScaffoldScreen> createState() => _ShellScaffoldScreenState();
}

class _ShellScaffoldScreenState extends ConsumerState<ShellScaffoldScreen> {
  void _onNavTap(int index) {
    widget.navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
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
