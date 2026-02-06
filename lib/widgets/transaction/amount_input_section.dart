import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mosa/models/enums.dart';
import 'package:mosa/utils/transaction_constants.dart';
import 'package:mosa/utils/utils.dart';
import 'package:mosa/widgets/amount_text_field.dart';
import 'package:mosa/widgets/card_section.dart';

/// Widget for amount input section in transaction screen
class AmountInputSection extends ConsumerWidget {
  final TextEditingController controller;
  final TransactionType? transactionType;

  const AmountInputSection({
    super.key,
    required this.controller,
    this.transactionType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CardSection(
      child: Column(
        children: [
          Text(TransactionConstants.amountLabel),
          AmountTextField(
            controller: controller,
            amountColor: getTransactionTypeColor(type: transactionType ?? TransactionType.expense),
          ),
        ],
      ),
    );
  }
}
