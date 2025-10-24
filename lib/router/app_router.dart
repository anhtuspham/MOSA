import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/router/app_routes.dart';
import 'package:mosa/screens/home_screen/home_screen.dart';

import '../screens/transaction_screen/add_transaction_screen.dart';

final goRouter = GoRouter(
  initialLocation: AppRoutes.home,
  debugLogDiagnostics: true,

  routes: [
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) {
        return HomeScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.addTransaction,
      name: 'addTransaction',
      builder: (context, state) {
        return AddTransactionScreen();
      },
    )


  ],
  errorBuilder: (context, state) {
    return Scaffold(
        appBar: AppBar(title: Text('Lỗi trang'),),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Router không tồn tại'),
              const SizedBox(height: 12),
              Text('Path: ${state.uri} không tồn tại. Vui lòng kiểm tra lại', style: TextStyle(color: Colors.grey),),
              const SizedBox(height: 32),
              ElevatedButton(onPressed: () => context.go(AppRoutes.home), child: Text('Quay về trang chủ'))
            ],
          ),
        )
    );
  },
);