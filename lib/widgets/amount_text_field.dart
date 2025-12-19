import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';
import '../utils/number_input_formatter.dart';

class AmountTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final Color? amountColor;
  final double fontSize;
  final String currency;

  const AmountTextField({
    super.key,
    required this.controller,
    this.hintText = '0',
    this.amountColor,
    this.fontSize = 32,
    this.currency = 'đ',
  });

  @override
  Widget build(BuildContext context) {
    final effectiveAmountColor = amountColor ?? AppColors.expense;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: IntrinsicWidth(
            child: TextField(
              controller: controller,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                counterText: '',
                isDense: true,
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: effectiveAmountColor.withValues(alpha: 0.9),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 4,
                ),
              ),
              maxLength: 15,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: effectiveAmountColor,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandSeparatorFormatter(separator: ',')],
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          currency,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: effectiveAmountColor,
          ),
        ),
      ],
    );
  }
}
