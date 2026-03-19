import 'package:flutter/material.dart';

class LoadingSectionWidget extends StatelessWidget {
  const LoadingSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
