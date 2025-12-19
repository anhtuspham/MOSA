import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosa/models/category.dart';
import 'package:mosa/models/enums.dart';
import 'package:mosa/models/transaction.dart';
import 'package:mosa/providers/wallet_provider.dart';
import 'package:mosa/utils/helpers.dart';
import 'package:mosa/utils/utils.dart';
import 'package:mosa/widgets/error_widget.dart';
import 'package:mosa/widgets/loading_widget.dart';
import '../utils/app_colors.dart';

class TransactionItem extends ConsumerWidget {
  final Category category;
  final TransactionModel transaction;

  const TransactionItem({
    super.key,
    required this.category,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletController = ref.watch(
      getWalletByIdProvider(transaction.walletId),
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
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
                Text(transaction.title),
                if (transaction.note != null)
                  Text(
                    transaction.note!,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Helpers.formatCurrency(transaction.amount),
                style: TextStyle(
                  fontSize: 16.sp,
                  color: getTransactionTypeColor(
                    type: getTransactionType(category.type),
                  ),
                ),
              ),
              walletController.when(
                data: (wallet) {
                  return Row(
                    children: [
                      Image.asset(wallet?.iconPath ?? '', width: 20),
                      const SizedBox(width: 4),
                      Text(
                        wallet?.name ?? '',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
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
