import 'package:flutter/material.dart';

class SettingsShellScreen extends StatelessWidget {
  const SettingsShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.settings, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Cài đặt ứng dụng'),
          SizedBox(height: 8),
          Text('Sẽ implement ở Day 11', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}