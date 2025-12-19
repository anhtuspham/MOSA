import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import 'custom_list_tile.dart';

class TextSelectorSection extends StatelessWidget {
  final TextEditingController controller;
  final void Function()? onTap;
  final String hintText;
  final Widget leading;
  const TextSelectorSection({
    super.key,
    required this.controller,
    this.onTap,
    required this.hintText,
    required this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return CustomListTile(
      leading: leading,
      title: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 14, color: AppColors.textHint),
          contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          border: OutlineInputBorder(borderSide: BorderSide.none),
        ),
        style: TextStyle(fontSize: 14),
        maxLines: 1,
      ),
      onTap: onTap,
    );
  }
}
