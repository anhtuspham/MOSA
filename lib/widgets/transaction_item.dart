import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosa/models/category.dart';
import 'package:mosa/models/enums.dart';
import 'package:mosa/providers/wallet_provider.dart';
import 'package:mosa/utils/helpers.dart';
import 'package:mosa/widgets/error_widget.dart';
import 'package:mosa/widgets/loading_widget.dart';
import '../utils/app_colors.dart';

class TransactionItem extends ConsumerWidget {
  final Category category;
  final String? note;
  final double amount;
  final int walletId;

  const TransactionItem({super.key, required this.category, this.note, required this.amount, required this.walletId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletController = ref.watch(getWalletByIdProvider(walletId));
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          category.getIcon(),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.name),
                if (note != null) Text(note!, style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Helpers.formatCurrency(amount),
                style: TextStyle(
                  fontSize: 16.sp,
                  color: category.type == 'income' ? AppColors.income : AppColors.expense,
                ),
              ),
              walletController.when(
                data: (wallet) {
                  return Row(
                    children: [
                      Image.asset(wallet?.iconPath ?? '', width: 20),
                      const SizedBox(width: 4),
                      Text(wallet?.name ?? '', style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary)),
                    ],
                  );
                },
                error: (error, stackTrace) => ErrorSectionWidget(error: error),
                loading: () => LoadingSectionWidget(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
