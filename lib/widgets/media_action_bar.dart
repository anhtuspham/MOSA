import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class MediaActionBar extends StatelessWidget {
  final VoidCallback? onMicTap;
  final VoidCallback? onImageTap;
  final VoidCallback? onCameraTap;
  final Color? dividerColor;
  final double dividerHeight;

  const MediaActionBar({
    super.key,
    this.onMicTap,
    this.onImageTap,
    this.onCameraTap,
    this.dividerColor,
    this.dividerHeight = 50,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveDividerColor = dividerColor ?? AppColors.borderLight;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: IconButton(
            onPressed: onMicTap,
            icon: Icon(Icons.mic_none_sharp),
          ),
        ),
        _buildDivider(effectiveDividerColor),
        Expanded(
          child: IconButton(
            onPressed: onImageTap,
            icon: Icon(Icons.image_outlined),
          ),
        ),
        _buildDivider(effectiveDividerColor),
        Expanded(
          child: IconButton(
            onPressed: onCameraTap,
            icon: Icon(Icons.camera_alt_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(Color color) {
    return Container(
      color: color,
      width: 1,
      height: dividerHeight,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
