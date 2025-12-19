import 'package:flutter/material.dart';

class ErrorSectionWidget extends StatelessWidget {
  final Object error;
  const ErrorSectionWidget({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(child: Text('Error: ${error.toString()}')),
    );
  }
}
