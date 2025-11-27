import 'package:flutter/material.dart';
import 'package:mosa/utils/app_colors.dart';

class CustomExpansionTile extends StatelessWidget {
  final bool? initialExpand;
  final Widget header;
  final List<Widget> children;
  const CustomExpansionTile({super.key, this.initialExpand, required this.header, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background
      ),
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 3),
      child: ExpansionTile(
        initiallyExpanded: initialExpand ?? false,
        title: header,
        shape: OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
        backgroundColor: AppColors.background,
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        dense: true,
        childrenPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        children: children,
      ),
    );
  }
}
