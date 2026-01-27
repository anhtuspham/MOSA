import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/config/section_container_config.dart';
import 'package:mosa/providers/debt_provider.dart';
import 'package:mosa/widgets/common_scaffold.dart';
import 'package:mosa/widgets/section_container.dart';

import '../../router/app_routes.dart';
import '../../utils/app_colors.dart';
import '../../utils/helpers.dart';
import '../../utils/toast.dart';
import '../../widgets/custom_expansion_tile.dart';
import '../../widgets/custom_list_tile.dart';
import '../../widgets/custom_modal_bottom_sheet.dart';
import '../../widgets/progress_info_item.dart';

class LoanTrackingScreen extends ConsumerStatefulWidget {
  const LoanTrackingScreen({super.key});

  @override
  ConsumerState<LoanTrackingScreen> createState() => _LoanTrackingScreenState();
}

class _LoanTrackingScreenState extends ConsumerState<LoanTrackingScreen> {
  @override
  Widget build(BuildContext context) {
    final totalDebt = ref.watch(totalDebtProvider);
    return CommonScaffold(
      title: Text("Theo dõi vay nợ"),
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back),
      ),
      actions: const [Icon(Icons.search)],
      appBarBackgroundColor: AppColors.background,
      tabs: [Tab(text: "Cho vay"), Tab(text: "Còn Nợ")],
      children: [
        loanTrackingContent('loan', totalAmount: totalDebt['lent'] ?? 0),
        loanTrackingContent('debt', totalAmount: totalDebt['borrowed'] ?? 0)
      ],
    );
  }

  Widget loanTrackingContent(String typeLoan, {required double totalAmount}) {
    bool isLoan = typeLoan == 'loan';
    // Calculate collected/paid amount (for demo, using 80% progress)
    double collectedOrPaid = totalAmount * 0.8;
    double progress = totalAmount > 0 ? collectedOrPaid / totalAmount : 0;

    return SectionContainer(
      child: Column(
        children: [
          ProgressInfoItem(
            title: Text(isLoan ? 'Cần thu' : 'Phải trả'),
            currentProgress: progress,
            linearColors: AppColors.chartColors.first,
            trailing: Row(
              children: [
                Text(
                  Helpers.formatCurrency(totalAmount - collectedOrPaid),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                )
              ],
            ),
            bottomContent: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isLoan ? 'Đã thu' : 'Đã trả', style: TextStyle(fontSize: 12.sp)),
                    Text(
                      Helpers.formatCurrency(collectedOrPaid),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(isLoan ? 'Tổng cho vay' : 'Tổng đi vay', style: TextStyle(fontSize: 12.sp)),
                    Text(
                      Helpers.formatCurrency(totalAmount),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                    ),
                  ],
                ),
              ],
            ),
          ),
          CustomExpansionTile(
            initialExpand: true,
            header: Text('Đang theo dõi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: AppColors.textHighlight)),
            children: [
              CustomListTile(
                leading: CircleAvatar(child: Text('T')),
                title: Text('wallet.name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                trailing: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          Helpers.formatCurrency(10000),
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.textPrimary
                          ),
                        ),
                        Text(
                          Helpers.formatCurrency(totalAmount - collectedOrPaid),
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: AppColors.expense,
                          ),
                        ),
                      ],
                    ),
                    IconButton(onPressed: () => _handleShowBottomSheet(isLoan ? 'Thu nợ' : 'Trả nợ'), icon: Icon(Icons.more_vert, color: AppColors.textPrimary)),
                  ],
                ),
              ),
            ],
          ),
          CustomExpansionTile(
            initialExpand: false,
            header: Text('Đã hoàn thành', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: AppColors.success)),
            children: [
              CustomListTile(
                leading: CircleAvatar(child: Text('T')),
                title: Text('wallet.name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                trailing: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          Helpers.formatCurrency(10000),
                          style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.textPrimary
                          ),
                        ),
                        Text(
                          Helpers.formatCurrency(10000),
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: AppColors.expense,
                          ),
                        ),
                      ],
                    ),
                    IconButton(onPressed: () => _handleShowBottomSheet(isLoan ? 'Thu nợ' : 'Trả nợ'), icon: Icon(Icons.more_vert, color: AppColors.textPrimary)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleShowBottomSheet(String title) {
    showCustomBottomSheet(
        context: context,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          CustomListTile(
            leading: Icon(Icons.swap_horiz, size: 20),
            title: Text(Helpers.formatCurrency(10000), style: TextStyle(fontSize: 16)),
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
            title: Text('Số tiền khác', style: TextStyle(fontSize: 16)),
            onTap: () {
              context.pop(); // Close bottom sheet first
              showInfoToast('Tính năng đang trong giai đoạn phát triển.');
            },
            backgroundColor: Colors.transparent,
          ),
        ]
    );
  }
}
