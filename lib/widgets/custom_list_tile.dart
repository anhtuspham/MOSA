import 'package:flutter/material.dart';
import 'package:mosa/utils/app_colors.dart';

/// Một Custom List Tile có thể tùy chỉnh phần leading, title, trailing và hành động khi nhấn
class CustomListTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subTitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  // final bool enable;
  // Padding
  final double horizontalGap;
  final Color? backgroundColor;
  const CustomListTile({
    super.key,
    required this.title,
    this.leading,
    this.subTitle,
    this.trailing,
    this.onTap,
    // this.enable = false,
    this.horizontalGap = 20,
    this.backgroundColor = AppColors.surface,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      color: backgroundColor,
      child: Row(
        children: [
          // SizedBox(width: horizontalGap),
          if (leading != null) ...[leading!],
          SizedBox(width: horizontalGap),
          Expanded(child: _buildTitleAndSubtitlePart(title, subTitle)),
          if (trailing != null) ...[SizedBox(width: horizontalGap), trailing!],
        ],
      ),
    );
    return _buildInkWell(child);
  }

  Widget _buildInkWell(Widget child) {
    return InkWell(onTap: onTap, child: child);
  }

  Widget _buildTitleAndSubtitlePart(Widget title, Widget? subTitle) {
    if (subTitle != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [title, subTitle],
      );
    }
    return title;
  }
}
