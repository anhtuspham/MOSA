import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class SectionContainer extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const SectionContainer({super.key, required this.child, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: backgroundColor ?? AppColors.primaryBackground),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      child: child,
    );
  }
}
