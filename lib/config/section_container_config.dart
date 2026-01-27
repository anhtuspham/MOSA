import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class SectionContainerConfig {
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final BorderRadiusGeometry? borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  const SectionContainerConfig({
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.boxShadow,
  });

  // Default config
  static const SectionContainerConfig defaultConfig = SectionContainerConfig(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 18),
    backgroundColor: AppColors.primaryBackground,
    borderRadius: BorderRadius.all(Radius.circular(10)),
  );

  // Compact config with margin
  static const SectionContainerConfig compact = SectionContainerConfig(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    margin: EdgeInsets.only(bottom: 12),
    backgroundColor: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(10)),
  );

  // Card style config
  static const SectionContainerConfig card = SectionContainerConfig(
    padding: EdgeInsets.all(16),
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    backgroundColor: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(12)),
    boxShadow: [
      BoxShadow(
        color: Color(0x0F000000),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  );

  // List item config
  static const SectionContainerConfig listItem = SectionContainerConfig(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    margin: EdgeInsets.only(bottom: 8),
    backgroundColor: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );

  // No margin config
  static const SectionContainerConfig noMargin = SectionContainerConfig(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    backgroundColor: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(10)),
  );

  // No padding config
  static const SectionContainerConfig noPadding = SectionContainerConfig(
    padding: EdgeInsets.zero,
    margin: EdgeInsets.only(bottom: 12),
    backgroundColor: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(10)),
  );

  // Copy with method for customization
  SectionContainerConfig copyWith({
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    BorderRadiusGeometry? borderRadius,
    BoxBorder? border,
    List<BoxShadow>? boxShadow,
  }) {
    return SectionContainerConfig(
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      border: border ?? this.border,
      boxShadow: boxShadow ?? this.boxShadow,
    );
  }
}
