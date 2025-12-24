import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mosa/providers/wallet_provider.dart';
import 'package:mosa/utils/app_colors.dart';
import 'package:mosa/utils/app_icons.dart';
import 'package:mosa/utils/helpers.dart';
import 'package:mosa/widgets/custom_list_tile.dart';
import 'package:mosa/widgets/error_widget.dart';
import 'package:mosa/widgets/loading_widget.dart';

class AccountTabScreen extends ConsumerStatefulWidget {
  const AccountTabScreen({super.key});

  @override
  ConsumerState<AccountTabScreen> createState() => _AccountTabScreenState();
}

class _AccountTabScreenState extends ConsumerState<AccountTabScreen> {
  @override
  Widget build(BuildContext context) {
    final totalBalanceState = ref.watch(totalBalanceWalletProvider);
    final walletState = ref.watch(walletProvider);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.secondary),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tổng tiền', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              totalBalanceState.when(
                data: (totalBalanceValue) {
                  return Text(
                    Helpers.formatCurrency(totalBalanceValue),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: totalBalanceValue >= 0 ? AppColors.textPrimary : AppColors.expense,
                    ),
                  );
                },
                error: (error, stackTrace) => ErrorSectionWidget(error: error),
                loading: () => LoadingSectionWidget(),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: SingleChildScrollView(
            child: Column(
              children: [
                walletState.when(
                  data: (wallets) {
                    return Column(
                      children: List.generate(wallets.length, (index) {
                        final wallet = wallets[index];
                        return CustomListTile(
                          leading: Image.asset(wallet.iconPath, width: 30),
                          title: Text(wallet.name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                          subTitle: Text(
                            Helpers.formatCurrency(wallet.balance),
                            style: TextStyle(color: wallet.balance >= 0 ? AppColors.textPrimary : AppColors.expense),
                          ),
                          trailing: IconButton(
                            onPressed: _handleShowBottomSheet,
                            icon: Icon(Icons.more_vert, color: AppColors.textPrimary),
                          ),
                        );
                      }),
                    );
                  },
                  loading: () => LoadingSectionWidget(),
                  error: (error, stackTrace) => ErrorSectionWidget(error: error),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _handleShowBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(leading: Icon(Icons.swap_horiz, size: 20), title: Text('Chuyển khoản'), dense: true),
              ListTile(leading: Icon(Icons.currency_exchange, size: 20), title: Text('Điều chỉnh số dư'), dense: true),
              ListTile(leading: Icon(Icons.share, size: 20), title: Text('Chia sẻ tài khoản'), dense: true),
              ListTile(leading: Icon(Icons.edit, size: 20), title: Text('Sửa'), dense: true),
              ListTile(leading: Icon(Icons.delete, size: 20), title: Text('Xóa'), dense: true),
              ListTile(leading: Icon(Icons.lock, size: 20), title: Text('Ngừng sử dụng'), dense: true),
            ],
          ),
    );
  }
}
