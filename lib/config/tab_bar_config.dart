import 'package:flutter/material.dart';
import 'package:mosa/utils/app_colors.dart';

/// Configuration class for TabBar styling and behavior.
///
/// This class provides a centralized way to configure TabBar appearance
/// across the application. It allows for consistent theming and easy
/// customization of tab indicators, text styles, and colors.
class TabBarConfig {
  /// Color of the active tab indicator line
  final Color indicatorColor;

  /// Size of the indicator relative to the tab
  final TabBarIndicatorSize indicatorSize;

  /// Text style for selected/active tab
  final TextStyle labelStyle;

  /// Text style for unselected/inactive tabs
  final TextStyle unselectedLabelStyle;

  /// Background color of the AppBar
  final Color backgroundColor;

  /// Height of the indicator line
  final double indicatorWeight;

  /// Physics for TabBarView scrolling behavior
  final ScrollPhysics? physics;

  /// Padding around tab content
  final EdgeInsetsGeometry? labelPadding;

  /// Indicator color when tab is disabled (if applicable)
  final Color? disabledIndicatorColor;

  const TabBarConfig({
    this.indicatorColor = AppColors.primary,
    this.indicatorSize = TabBarIndicatorSize.tab,
    TextStyle? labelStyle,
    TextStyle? unselectedLabelStyle,
    this.backgroundColor = Colors.transparent,
    this.indicatorWeight = 2.0,
    this.physics,
    this.labelPadding,
    this.disabledIndicatorColor,
  }) : labelStyle =
           labelStyle ??
           const TextStyle(
             color: AppColors.textHighlight,
             fontWeight: FontWeight.bold,
           ),
       unselectedLabelStyle =
           unselectedLabelStyle ??
           const TextStyle(
             color: AppColors.textPrimary,
             fontWeight: FontWeight.w500,
           );

  /// Default TabBar configuration - matches current app styling
  factory TabBarConfig.defaultConfig() {
    return const TabBarConfig(
      indicatorColor: AppColors.primary,
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: TextStyle(
        color: AppColors.textHighlight,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// Light theme configuration
  factory TabBarConfig.light() {
    return const TabBarConfig(
      indicatorColor: AppColors.primary,
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: TextStyle(
        color: AppColors.textHighlight,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      unselectedLabelStyle: TextStyle(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      backgroundColor: AppColors.surface,
    );
  }

  /// Dark theme configuration
  factory TabBarConfig.dark() {
    return const TabBarConfig(
      indicatorColor: AppColors.secondary,
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: TextStyle(
        color: AppColors.secondary,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      unselectedLabelStyle: TextStyle(
        color: Colors.grey,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      backgroundColor: Colors.grey,
    );
  }

  /// Create a copy of this config with some properties changed
  TabBarConfig copyWith({
    Color? indicatorColor,
    TabBarIndicatorSize? indicatorSize,
    TextStyle? labelStyle,
    TextStyle? unselectedLabelStyle,
    Color? backgroundColor,
    double? indicatorWeight,
    ScrollPhysics? physics,
    EdgeInsetsGeometry? labelPadding,
    Color? disabledIndicatorColor,
  }) {
    return TabBarConfig(
      indicatorColor: indicatorColor ?? this.indicatorColor,
      indicatorSize: indicatorSize ?? this.indicatorSize,
      labelStyle: labelStyle ?? this.labelStyle,
      unselectedLabelStyle: unselectedLabelStyle ?? this.unselectedLabelStyle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      indicatorWeight: indicatorWeight ?? this.indicatorWeight,
      physics: physics ?? this.physics,
      labelPadding: labelPadding ?? this.labelPadding,
      disabledIndicatorColor:
          disabledIndicatorColor ?? this.disabledIndicatorColor,
    );
  }
}
