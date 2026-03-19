import 'package:flutter/material.dart';

/// Container dùng để bọc các logo (ngân hàng, ví điện tử) với nền trắng và viền
class LogoContainer extends StatelessWidget {
  final String assetPath;
  final double size;
  final double padding;

  const LogoContainer({
    super.key,
    required this.assetPath,
    this.size = 28,
    this.padding = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white, // Nền trắng đảm bảo logo luôn nổi bật bất kể theme
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}
