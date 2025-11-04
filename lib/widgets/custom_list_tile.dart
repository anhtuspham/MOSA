import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/router/app_routes.dart';

/// Một Custom List Tile có thể tùy chỉnh phần leading, title, trailing và hành động khi nhấn
class CustomListTile extends StatefulWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? trailing;
  final VoidCallback? onTap;
  const CustomListTile({super.key, this.leading, this.title, this.trailing, this.onTap});

  @override
  State<CustomListTile> createState() => _CustomListTileState();
}

class _CustomListTileState extends State<CustomListTile> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            widget.leading ?? const SizedBox(),
            SizedBox(width: 12),
            widget.title ?? const SizedBox(),
            Spacer(),
            widget.trailing ?? const SizedBox(),
          ],
        ),
      ),
      onTap: () {
        context.push(AppRoutes.categoryList);
      },
    );
  }
}
