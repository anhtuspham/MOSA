import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/router/app_routes.dart';

class ShellScaffoldScreen extends StatefulWidget {
  final Widget child;
  final StatefulNavigationShell navigationShell;

  const ShellScaffoldScreen({super.key, required this.child, required this.navigationShell});

  @override
  State<ShellScaffoldScreen> createState() => _ShellScaffoldScreenState();
}

class _ShellScaffoldScreenState extends State<ShellScaffoldScreen> {

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
        context.go(AppRoutes.history);
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
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Xin chào!', style: TextStyle(fontSize: 12.sp)),
            Text('Pham Anh Tu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
          ],
        ),
        leading: Container(margin: EdgeInsets.only(left: 8.w), child: CircleAvatar(radius: 20, backgroundColor: Colors.blueAccent, child: Text('P'))),
        actionsPadding: EdgeInsets.symmetric(horizontal: 12.w),
        actions: [
          Icon(Icons.sync, color: Colors.white),
          const SizedBox(width: 8),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.notifications, color: Colors.white, size: 28),
              Positioned(
                right: -1,
                top: -8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                  child: Text('3', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          indicatorColor: Colors.black,
          indicatorSize: TabBarIndicatorSize.tab,
          unselectedLabelStyle: TextStyle(color: Colors.white),
          labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          tabs: [Tab(child: Text('Tất cả')), Tab(child: Text('Thu nhập ')), Tab(child: Text('Chi tiêu'))],
        ),
      ),
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _getSelectedIndex(),
        onDestinationSelected: _onNavTap,
        destinations: [
          NavigationDestination(icon: Icon(Icons.home_filled), label: 'Tổng quan'),
          NavigationDestination(icon: Icon(Icons.wallet), label: 'Tài khoản'),
          NavigationDestination(icon: Icon(Icons.add_circle_outlined), label: 'Ghi chép'),
          NavigationDestination(icon: Icon(Icons.analytics), label: 'Thống kê'),
          NavigationDestination(icon: Icon(Icons.widgets_outlined), label: 'Cài đặt'),
        ],
      ),
    );
  }
}
