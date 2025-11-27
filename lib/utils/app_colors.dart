import 'package:flutter/material.dart';

class AppColors {
  // Primary App Colors
  static const Color primary = Color(0xFF2196F3);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color third = Color.fromARGB(255, 62, 164, 247);
  static const Color fourth = Color.fromARGB(255, 99, 154, 199);
  // static const Color background = Color(0xFFF5F5F5);
  static const Color background = Color(0xFFF5F5F5);
  static const Color primaryBackground = Color.fromARGB(255, 223, 240, 253);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color secondaryBackground = Color.fromARGB(255, 233, 232, 232);

  // Gold app colors
  static const Color goldColor = Color(0xFFed8509);
  static const Color lightGoldColor = Color(0xFFe5970b);
  static const Color lighterGoldColor = Color(0xffe5970c);

  static const Color primaryBlue = Color(0xFF0a84fa);
  static const Color secondBlue = Color(0xFF0a83fa);
  static const Color thirdBlue = Color(0xFF01aef0);
  static const Color fourthBlue = Color(0xFF50defa);
  static const Color fifthBlue = Color(0xFF3d90fd);
  static const Color sixthBlue = Color.fromARGB(255, 59, 179, 223);

  // background colors
  static const Color firstBackGroundColor = Color.fromARGB(255, 231, 231, 231);
  static const Color lightBackGroundColor = Color.fromARGB(255, 223, 237, 250);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textWhite = Color(0xFFffffff);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textHighlight = Color(0xFF2196F3);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Transaction Colors
  static const Color income = Color(0xFF4CAF50);
  static const Color expense = Color(0xFFF44336);

  // Border colors
  static const Color lightBorder = Color.fromARGB(255, 82, 97, 126);
  static const Color border = Color(0xFF898989);
  static const Color borderLight = Color(0xFFAEAEAE);
  static const Color borderLighter = Color(0xFFF5F5F5);

  // Button colors
  static const Color buttonPrimary = Color(0xFF008fd3);

  // 20 Chart Colors - Vibrant & Distinguishable
  static const List<Color> chartColors = [
    Color(0xFF2196F3), // Blue
    Color(0xFFFF5722), // Deep Orange
    Color(0xFF4CAF50), // Green
    Color(0xFFFF9800), // Orange
    Color(0xFF9C27B0), // Purple
    Color(0xFF00BCD4), // Cyan
    Color(0xFFE91E63), // Pink
    Color(0xFF8BC34A), // Light Green
    Color(0xFFFFEB3B), // Yellow
    Color(0xFF673AB7), // Deep Purple
    Color(0xFF009688), // Teal
    Color(0xFFFFC107), // Amber
    Color(0xFF3F51B5), // Indigo
    Color(0xFFFF6F00), // Orange Accent
    Color(0xFF00E676), // Green Accent
    Color(0xFF76FF03), // Light Green Accent
    Color(0xFFAA00FF), // Purple Accent
    Color(0xFF00B0FF), // Light Blue Accent
    Color(0xFFFF1744), // Red Accent
    Color(0xFF00E5FF), // Cyan Accent
  ];

  // Category Colors Map - Assign specific colors to categories
  static const Map<String, Color> categoryColors = {
    'Ăn uống': Color(0xFFFF9800), // Orange
    'Di chuyển': Color(0xFF2196F3), // Blue
    'Giải trí': Color(0xFF9C27B0), // Purple
    'Mua sắm': Color(0xFFE91E63), // Pink
    'Nhà cửa': Color(0xFF4CAF50), // Green
    'Y tế': Color(0xFFF44336), // Red
    'Giáo dục': Color(0xFF673AB7), // Deep Purple
    'Tiết kiệm': Color(0xFF00BCD4), // Cyan
    'Đầu tư': Color(0xFF3F51B5), // Indigo
    'Quà tặng': Color(0xFFFF5722), // Deep Orange
    'Hóa đơn': Color(0xFF009688), // Teal
    'Khác': Color(0xFF757575), // Grey
  };

  // Get color by index (for dynamic categories)
  static Color getChartColor(int index) {
    return chartColors[index % chartColors.length];
  }

  // Get color by category name
  static Color getCategoryColor(String category) {
    return categoryColors[category] ?? chartColors[0];
  }

  // Generate lighter shade (for backgrounds)
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  // Generate darker shade
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  // Get contrasting text color (white or black)
  static Color getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
