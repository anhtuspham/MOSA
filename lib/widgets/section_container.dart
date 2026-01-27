import 'package:flutter/material.dart';

import '../config/section_container_config.dart';

class SectionContainer extends StatelessWidget {
  final Widget child;
  final SectionContainerConfig? config;

  const SectionContainer({
    super.key,
    required this.child,
    this.config,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveConfig = config ?? SectionContainerConfig.defaultConfig;

    return Container(
      margin: effectiveConfig.margin,
      padding: effectiveConfig.padding,
      decoration: BoxDecoration(
        color: effectiveConfig.backgroundColor,
        borderRadius: effectiveConfig.borderRadius,
        border: effectiveConfig.border,
        boxShadow: effectiveConfig.boxShadow,
      ),
      child: child,
    );
  }
}
