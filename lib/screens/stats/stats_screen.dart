import 'package:flutter/material.dart';

class StatsShellScreen extends StatelessWidget {
  const StatsShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.analytics, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Thống kê chi tiêu'),
          SizedBox(height: 8),
          Text('Sẽ implement ở Day 8-9', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}