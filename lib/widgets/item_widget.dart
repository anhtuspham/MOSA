import 'package:flutter/material.dart';

class ItemWidget extends StatelessWidget {
  final String iconPath;
  final String title;
  final VoidCallback onTap;
  const ItemWidget({super.key, required this.iconPath, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(iconPath, width: 25),
          Text(
            title,
            style: TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
