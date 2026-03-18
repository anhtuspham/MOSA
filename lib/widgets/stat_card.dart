import 'package:flutter/material.dart';
import 'package:mosa/config/app_colors.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String amount;
  final VoidCallback? onTap;

  const StatCard({super.key, required this.title, required this.amount, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withValues(alpha: 0.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 6),
                Text(
                  amount,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.3)),
              child: Icon(Icons.arrow_forward_rounded, color: Theme.of(context).textTheme.bodyMedium?.color, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}
