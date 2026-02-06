import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mosa/providers/wallet_provider.dart';
import 'package:mosa/utils/app_colors.dart';
import 'package:mosa/utils/helpers.dart';
import 'package:mosa/utils/number_input_formatter.dart';
import 'package:mosa/utils/transaction_constants.dart';
import 'package:mosa/widgets/card_section.dart';
import 'package:mosa/widgets/custom_list_tile.dart';
import 'package:mosa/widgets/error_widget.dart';
import 'package:mosa/widgets/loading_widget.dart';

/// Widget for balance adjustment section
class AdjustBalanceSection extends ConsumerWidget {
  final TextEditingController actualBalanceController;

  const AdjustBalanceSection({
    super.key,
    required this.actualBalanceController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveWallet = ref.watch(effectiveWalletProvider);
    
    return effectiveWallet.when(
      data: (wallet) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          actualBalanceController.text = Helpers.formatNumber(wallet.balance);
        });

        return CardSection(
          child: Column(
            children: [
              CustomListTile(
                title: Text(TransactionConstants.balanceOnAccount),
                trailing: Text(Helpers.formatCurrency(wallet.balance)),
              ),
              const SizedBox(height: 12),
              CustomListTile(
                title: Text(TransactionConstants.actualBalance),
                trailing: SizedBox(
                  width: 200,
                  child: TextField(
                    controller: actualBalanceController,
                    decoration: InputDecoration(
                      counterText: '',
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.borderLight),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      hintText: TransactionConstants.enterActualBalance,
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                      suffix: Text(
                        TransactionConstants.currencySymbol,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    maxLength: 16,
                    textAlign: TextAlign.right,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [ThousandSeparatorFormatter(separator: '.')],
                  ),
                ),
              ),
              ValueListenableBuilder(
                valueListenable: actualBalanceController,
                builder: (context, value, child) {
                  final actualBalance = double.tryParse(
                    actualBalanceController.text.replaceAll('.', '')
                  ) ?? 0;
                  final different = actualBalance - wallet.balance;
                  
                  return CustomListTile(
                    title: Text(
                      different > 0 
                          ? TransactionConstants.received 
                          : TransactionConstants.spent
                    ),
                    trailing: Text(
                      Helpers.formatCurrency(different),
                      style: TextStyle(
                        color: different > 0 
                            ? AppColors.income 
                            : AppColors.expense,
                        fontSize: 18,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
      error: (error, stackTrace) => ErrorSectionWidget(error: error),
      loading: () => const LoadingSectionWidget(),
    );
  }
}
