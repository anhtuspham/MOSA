import 'package:flutter/material.dart';

/// Một Custom List Tile có thể tùy chỉnh phần leading, title, trailing và hành động khi nhấn
class CustomListTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subTitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enable;
  // Padding
  final double horizontalGap;
  const CustomListTile({
    super.key,
    required this.title,
    this.leading,
    this.subTitle,
    this.trailing,
    this.onTap,
    this.enable = false,
    this.horizontalGap = 20,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
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
    return InkWell(onTap: enable ? onTap : null, child: child);
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
