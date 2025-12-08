import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class SectionContainer extends StatelessWidget {
  final Widget child;

  const SectionContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.primaryBackground),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      child: child,
    );
  }
}
