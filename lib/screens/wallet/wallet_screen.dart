import 'package:flutter/material.dart';

class WalletShellScreen extends StatelessWidget {
  const WalletShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.wallet, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Quản lý tài khoản'),
          SizedBox(height: 8),
          Text('Sẽ implement ở Day 8', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}