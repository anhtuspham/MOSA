import 'package:flutter/material.dart';
import 'package:mosa/utils/app_colors.dart';

/// Configuration class for TabBar styling and behavior.
///
/// This immutable class provides a centralized, type-safe way to configure TabBar
/// appearance across the application. It encapsulates all visual properties of
/// TabBar widgets to ensure consistent theming and simplify customization.
///
/// ## Usage
///
/// ### Using default configuration:
/// ```dart
/// CommonScaffold(
///   title: Text('Stats'),
///   tabs: [...],
///   tabBarConfig: TabBarConfig.defaultConfig(),
/// )
/// ```
///
/// ### Using theme-specific configurations:
/// ```dart
/// // Light theme
/// tabBarConfig: TabBarConfig.light()
///
/// // Dark theme
/// tabBarConfig: TabBarConfig.dark()
/// ```
///
/// ### Creating custom configuration:
/// ```dart
/// TabBarConfig(
///   indicatorColor: Colors.blue,
///   indicatorWeight: 3.0,
///   labelStyle: TextStyle(fontWeight: FontWeight.bold),
///   physics: NeverScrollableScrollPhysics(),
/// )
/// ```
///
/// ### Modifying existing configuration:
/// ```dart
/// final customConfig = TabBarConfig.defaultConfig().copyWith(
///   indicatorColor: Colors.red,
///   indicatorWeight: 4.0,
/// );
/// ```
///
/// ## Design Decisions
///
/// - **Immutable**: All fields are final to prevent accidental mutations
/// - **Factory constructors**: Provide pre-configured themes for consistency
/// - **Null-safe defaults**: Constructor provides sensible defaults for optional parameters
/// - **copyWith method**: Enables easy customization of existing configurations
class TabBarConfig {
  /// Color of the active tab indicator line.
  ///
  /// This is the underline color that appears beneath the selected tab.
  /// Defaults to [AppColors.primary] for brand consistency.
  final Color indicatorColor;

  /// Size of the indicator relative to the tab.
  ///
  /// Options:
  /// - [TabBarIndicatorSize.tab]: Indicator spans the full tab width
  /// - [TabBarIndicatorSize.label]: Indicator only spans the label text width
  final TabBarIndicatorSize indicatorSize;

  /// Text style for the currently selected/active tab.
  ///
  /// Applied to the tab that the user has navigated to.
  /// Defaults to bold text with [AppColors.textHighlight] color.
  final TextStyle labelStyle;

  /// Text style for unselected/inactive tabs.
  ///
  /// Applied to tabs that are not currently selected.
  /// Defaults to medium weight text with [AppColors.textPrimary] color.
  final TextStyle unselectedLabelStyle;

  /// Background color of the AppBar containing the TabBar.
  ///
  /// Defaults to [Colors.transparent] to inherit from parent AppBar.
  final Color backgroundColor;

  /// Thickness of the indicator line in logical pixels.
  ///
  /// Defaults to 2.0. Increase for more prominent tab selection feedback.
  final double indicatorWeight;

  /// Physics for TabBarView scrolling behavior.
  ///
  /// Controls how the tab view responds to user gestures. Common values:
  /// - null: Default scrollable behavior
  /// - [NeverScrollableScrollPhysics]: Disable swipe gestures between tabs
  /// - [BouncingScrollPhysics]: iOS-style bounce effect
  /// - [ClampingScrollPhysics]: Android-style edge glow effect
  final ScrollPhysics? physics;

  /// Padding applied around each tab's content (text/icon).
  ///
  /// Useful for adjusting tab spacing in dense or sparse layouts.
  final EdgeInsetsGeometry? labelPadding;

  /// Indicator color when tab is disabled.
  ///
  /// Currently unused but reserved for future disabled tab state support.
  final Color? disabledIndicatorColor;

  /// Creates a TabBarConfig with the specified styling options.
  ///
  /// All parameters are optional and have sensible defaults:
  /// - [indicatorColor]: Primary app color
  /// - [indicatorSize]: Full tab width
  /// - [labelStyle]: Bold text with highlight color
  /// - [unselectedLabelStyle]: Medium weight text with primary text color
  /// - [backgroundColor]: Transparent to inherit from parent
  /// - [indicatorWeight]: 2.0 logical pixels
  /// - [physics]: Default scrollable behavior
  /// - [labelPadding]: Default Material padding
  /// - [disabledIndicatorColor]: Not used currently
  ///
  /// The constructor is marked `const` for compile-time optimization.
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

  /// Creates the default TabBar configuration for the app.
  ///
  /// This is the primary configuration used throughout the application and
  /// matches the standard app styling guidelines. It uses:
  /// - Primary brand color for the indicator
  /// - Bold text for selected tabs
  /// - Medium weight text for unselected tabs
  /// - Full-width tab indicators
  ///
  /// Use this when you want the standard app appearance without customization.
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

  /// Creates a TabBar configuration optimized for light theme.
  ///
  /// Provides enhanced readability in light backgrounds with:
  /// - Slightly larger font size (14px) for better visibility
  /// - Surface background color for contrast
  /// - Secondary text color for unselected tabs
  ///
  /// Use this when the app is in light mode or for screens with bright backgrounds.
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

  /// Creates a TabBar configuration optimized for dark theme.
  ///
  /// Provides good contrast in dark backgrounds with:
  /// - Secondary accent color for indicator and selected tabs
  /// - Grey color scheme for reduced eye strain
  /// - Explicit font sizes for consistency
  ///
  /// Use this when the app is in dark mode or for screens with dark backgrounds.
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

  /// Creates a copy of this configuration with some properties overridden.
  ///
  /// This method enables immutable updates to existing configurations.
  /// Only the provided parameters will be changed; all others retain their current values.
  ///
  /// Example:
  /// ```dart
  /// final baseConfig = TabBarConfig.defaultConfig();
  /// final customConfig = baseConfig.copyWith(
  ///   indicatorWeight: 4.0,
  ///   physics: NeverScrollableScrollPhysics(),
  /// );
  /// ```
  ///
  /// This is particularly useful when you want to customize a standard configuration
  /// without creating an entirely new config from scratch.
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
