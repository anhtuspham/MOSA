import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/providers/wallet_provider.dart';
import 'package:mosa/router/app_routes.dart';
import 'package:mosa/widgets/custom_list_tile.dart';
import 'package:mosa/widgets/error_widget.dart';
import 'package:mosa/widgets/loading_widget.dart';
import 'package:mosa/widgets/logo_container.dart';

/// Widget for wallet selection section
class WalletSelectorSection extends ConsumerWidget {
  const WalletSelectorSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveWallet = ref.watch(effectiveWalletProvider);

    return effectiveWallet.when(
      data: (walletData) {
        return CustomListTile(
          leading: LogoContainer(assetPath: walletData.iconPath, size: 18),
          title: Text(walletData.name),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            context.push(AppRoutes.selectWallet);
          },
        );
      },
      error: (error, stackTrace) => ErrorSectionWidget(error: error),
      loading: () => const LoadingSectionWidget(),
    );
  }
}
