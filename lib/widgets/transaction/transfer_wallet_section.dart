import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/providers/wallet_provider.dart';
import 'package:mosa/router/app_routes.dart';
import 'package:mosa/utils/app_colors.dart';
import 'package:mosa/utils/app_icons.dart';
import 'package:mosa/utils/transaction_constants.dart';
import 'package:mosa/widgets/card_section.dart';
import 'package:mosa/widgets/custom_list_tile.dart';

/// Widget for transfer wallet selection (from/to)
class TransferWalletSection extends ConsumerWidget {
  final String? title;
  final bool isTransferOut;

  const TransferWalletSection({
    super.key,
    this.title,
    this.isTransferOut = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = isTransferOut 
        ? ref.watch(transferOutWalletProvider) 
        : ref.watch(transferInWalletProvider);
    final route = isTransferOut 
        ? AppRoutes.selectTransferOutWallet 
        : AppRoutes.selectTransferInWallet;

    return CardSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: Text(
                title!,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          CustomListTile(
            leading: Image.asset(
              wallet?.iconPath ?? AppIcons.plusIcon,
              width: 22,
            ),
            title: Text(wallet?.name ?? TransactionConstants.selectAccount),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(route),
          ),
        ],
      ),
    );
  }
}
