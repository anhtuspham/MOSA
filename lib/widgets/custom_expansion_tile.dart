import 'package:flutter/material.dart';
import 'package:mosa/utils/app_colors.dart';

class CustomExpansionTile extends StatelessWidget {
  final Widget title;
  final List<Widget> children;
  const CustomExpansionTile({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: title,
      backgroundColor: AppColors.background,
      dense: true,
      childrenPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      children: children,
    );
  }
}
