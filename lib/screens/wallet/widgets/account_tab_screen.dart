import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/models/wallets.dart';
import 'package:mosa/providers/wallet_provider.dart';
import 'package:mosa/router/app_routes.dart';
import 'package:mosa/utils/app_colors.dart';
import 'package:mosa/utils/app_icons.dart';
import 'package:mosa/utils/helpers.dart';
import 'package:mosa/utils/toast.dart';
import 'package:mosa/widgets/custom_list_tile.dart';
import 'package:mosa/widgets/custom_modal_bottom_sheet.dart';
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
    final totalBalance = ref.watch(totalBalanceWalletProvider);
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
              Text(
                Helpers.formatCurrency(totalBalance),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: totalBalance >= 0 ? AppColors.textPrimary : AppColors.expense,
                ),
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
                            onPressed: () => _handleShowBottomSheet(wallet),
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

  void _handleShowBottomSheet(Wallet wallet) {
    showCustomBottomSheet(
      context: context,
      children: [
        CustomListTile(
          leading: Icon(Icons.swap_horiz, size: 20),
          title: Text('Chuyển khoản', style: TextStyle(fontSize: 16)),
          onTap: () async {
            Navigator.pop(context); // Close bottom sheet with Navigator
            await Future.delayed(Duration(milliseconds: 150)); // Wait for close animation
            if (mounted) {
              context.go(AppRoutes.addTransaction);
            }
          },
          backgroundColor: Colors.transparent,
        ),
        CustomListTile(
          leading: Icon(Icons.currency_exchange, size: 20),
          title: Text('Điều chỉnh số dư', style: TextStyle(fontSize: 16)),
          onTap: () {
            context.pop(); // Close bottom sheet first
            showInfoToast('Tính năng đang trong giai đoạn phát triển.');
          },
          backgroundColor: Colors.transparent,
        ),
        CustomListTile(
          leading: Icon(Icons.share, size: 20),
          title: Text('Chia sẻ tài khoản', style: TextStyle(fontSize: 16)),
          onTap: () {
            context.pop(); // Close bottom sheet first
            showInfoToast('Tính năng đang trong giai đoạn phát triển.');
          },
          backgroundColor: Colors.transparent,
        ),
        CustomListTile(
          leading: Icon(Icons.edit, size: 20),
          title: Text('Sửa', style: TextStyle(fontSize: 16)),
          onTap: () {
            context.pop(); // Close bottom sheet first
            showInfoToast('Tính năng đang trong giai đoạn phát triển.');
          },
          backgroundColor: Colors.transparent,
        ),
        CustomListTile(
          leading: Icon(Icons.delete, size: 20),
          title: Text('Xóa', style: TextStyle(fontSize: 16)),
          onTap: () {
            context.pop(); // Close bottom sheet first
            _showDeleteConfirmation(wallet);
          },
          backgroundColor: Colors.transparent,
        ),
        CustomListTile(
          leading: Icon(Icons.lock, size: 20),
          title: Text('Ngừng sử dụng', style: TextStyle(fontSize: 16)),
          onTap: () {
            context.pop(); // Close bottom sheet first
            showInfoToast('Tính năng đang trong giai đoạn phát triển.');
          },
          backgroundColor: Colors.transparent,
        ),
      ]
    );
  }

  void _showDeleteConfirmation(Wallet wallet) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Xác nhận xóa'),
            content: Text('Bạn có chắc chắn muốn xóa ví "${wallet.name}"?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Hủy')),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleDeleteWallet(wallet);
                },
                child: Text('Xóa', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  Future<void> _handleDeleteWallet(Wallet wallet) async {
    await ref.read(walletProvider.notifier).deleteWallet(wallet.id ?? -99);

    if (!mounted) return;

    // Check the provider state to see if deletion succeeded or failed
    final walletState = ref.read(walletProvider);

    walletState.when(
      data: (_) {
        showResultToast('Đã xóa ví "${wallet.name}" thành công');
      },
      error: (error, _) {
        // Extract the actual error message from the exception
        final errorMessage = error.toString().replaceFirst('Exception: ', '');
        showResultToast(errorMessage, isError: true);
      },
      loading: () {}, // Do nothing while loading
    );
  }
}
