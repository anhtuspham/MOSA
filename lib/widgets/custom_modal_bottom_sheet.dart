import 'package:flutter/material.dart';

void showCustomBottomSheet({required BuildContext context, required List<Widget> children}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder:
        (context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children
      ),
    ),
  );
}