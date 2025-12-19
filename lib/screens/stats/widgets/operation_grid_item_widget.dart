import 'package:flutter/material.dart';
import 'package:mosa/utils/app_colors.dart';

class OperationGridItemWidget extends StatefulWidget {
  final String iconPath;
  final String title;
  const OperationGridItemWidget({
    super.key,
    required this.iconPath,
    required this.title,
  });

  @override
  State<OperationGridItemWidget> createState() =>
      _OperationGridItemWidgetState();
}

class _OperationGridItemWidgetState extends State<OperationGridItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: double.infinity),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(widget.iconPath, width: 20, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(widget.title),
        ],
      ),
    );
  }
}
