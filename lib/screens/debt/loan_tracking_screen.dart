import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/models/category.dart';
import 'package:mosa/models/debt.dart';
import 'package:mosa/models/enums.dart';
import 'package:mosa/providers/category_provider.dart';
import 'package:mosa/providers/debt_provider.dart';
import 'package:mosa/providers/person_provider.dart';
import 'package:mosa/providers/transaction_prefill_data_provider.dart';
import 'package:mosa/widgets/common_scaffold.dart';
import 'package:mosa/widgets/debt/person_debt_item.dart';
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
    final totalLentDebt = ref.watch(totalDebtByTypeProvider(DebtType.lent));
    final totalBorrowedDebt = ref.watch(totalDebtByTypeProvider(DebtType.borrowed));

    return CommonScaffold(
      title: Text("Theo dõi vay nợ"),
      leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back)),
      actions: const [Icon(Icons.search)],
      appBarBackgroundColor: AppColors.background,
      tabs: [Tab(text: "Cho vay"), Tab(text: "Còn Nợ")],
      children: [
        _loanTrackingContent(
          DebtType.lent,
          totalDebt: totalLentDebt.totalDebt,
          totalDebtPaid: totalLentDebt.totalDebtPaid,
          totalDebtRemaining: totalLentDebt.totalDebtRemaining,
        ),
        _loanTrackingContent(
          DebtType.borrowed,
          totalDebt: totalBorrowedDebt.totalDebt,
          totalDebtPaid: totalBorrowedDebt.totalDebtPaid,
          totalDebtRemaining: totalBorrowedDebt.totalDebtRemaining,
        ),
      ],
    );
  }

  Widget _loanTrackingContent(
    DebtType type, {
    required double totalDebt,
    required double totalDebtPaid,
    required double totalDebtRemaining,
  }) {
    final bool isLoan = type == DebtType.lent;

    // Debts chưa hoàn thành: Map<personId, remainingAmount>
    final activeDebtSummary = ref.watch(debtSummaryByTypeProvider(type));

    // Debts đã hoàn thành: Map<personId, totalAmount>
    final paidDebtSummary = ref.watch(debtSummaryPaidByTypeProvider(type));

    double progress = totalDebt != 0 ? totalDebtPaid / totalDebt : 0;

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
                  Helpers.formatCurrency(totalDebtRemaining),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                ),
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
                      Helpers.formatCurrency(totalDebtPaid),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(isLoan ? 'Tổng cho vay' : 'Tổng đi vay', style: TextStyle(fontSize: 12.sp)),
                    Text(
                      Helpers.formatCurrency(totalDebt),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- Đang theo dõi: debts active / partial ---
          CustomExpansionTile(
            initialExpand: true,
            header: Text(
              'Đang theo dõi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: AppColors.textHighlight),
            ),
            children:
                activeDebtSummary.entries
                    .map(
                      (e) => PersonDebtItem(
                        personId: e.key,
                        handleShowBottomSheet:
                            () => _handleShowBottomSheet(isLoan: isLoan, personId: e.key, totalDebtRemaining: e.value),
                      ),
                    )
                    .toList(),
          ),

          // --- Đã hoàn thành: debts paid ---
          CustomExpansionTile(
            initialExpand: false,
            header: Text(
              'Đã hoàn thành',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: AppColors.success),
            ),
            children:
                paidDebtSummary.entries.map((e) => _personPaidItem(personId: e.key, totalAmount: e.value)).toList(),
          ),
        ],
      ),
    );
  }

  /// Item trong section "Đã hoàn thành" -- chỉ hiển thị tổng và icon check
  Widget _personPaidItem({required int personId, required double totalAmount}) {
    final person = ref.watch(personByIdProvider(personId));

    return CustomListTile(
      leading: CircleAvatar(child: Text(person?.name.substring(0, 1).toUpperCase() ?? 'T')),
      title: Text(person?.name ?? 'Unknown', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp)),
      trailing: Row(
        children: [
          Text(Helpers.formatCurrency(totalAmount), style: TextStyle(fontSize: 16.sp, color: AppColors.textPrimary)),
          SizedBox(width: 8.w),
          Icon(Icons.check_circle, color: AppColors.success),
        ],
      ),
    );
  }

  void _handleShowBottomSheet({required bool isLoan, required int personId, required double totalDebtRemaining}) async {
    final title = isLoan ? 'Thu nợ' : 'Trả nợ';
    final debtCollectionCategory = await ref.read(categoryByNameProvider('Thu nợ').future);
    final debtRepaymentCategory = await ref.read(categoryByNameProvider('Trả nợ').future);
    final person = ref.read(personByIdProvider(personId));
    if (!mounted) return;
    showCustomBottomSheet(
      context: context,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        CustomListTile(
          leading: Icon(Icons.swap_horiz, size: 20),
          title: Text(Helpers.formatCurrency(totalDebtRemaining), style: TextStyle(fontSize: 16)),
          onTap: () async {
            Navigator.pop(context);
            await Future.delayed(Duration(milliseconds: 150));
            if (mounted) {
              final category = isLoan ? debtCollectionCategory : debtRepaymentCategory;
              ref.read(transactionPrefillDataProvider.notifier).state = TransactionPrefill(
                person: person,
                amount: totalDebtRemaining,
                type: TransactionType.income,
                category: category,
              );
              context.go(AppRoutes.addTransaction);
            }
          },
          backgroundColor: Colors.transparent,
        ),
        CustomListTile(
          leading: Icon(Icons.currency_exchange, size: 20),
          title: Text('Số tiền khác', style: TextStyle(fontSize: 16)),
          onTap: () {
            context.pop();
            if (mounted) {
              final category = isLoan ? debtCollectionCategory : debtRepaymentCategory;
              ref.read(transactionPrefillDataProvider.notifier).state = TransactionPrefill(
                person: person,
                amount: 0,
                type: TransactionType.income,
                category: category,
              );
              context.go(AppRoutes.addTransaction);
            }
          },
          backgroundColor: Colors.transparent,
        ),
      ],
    );
  }
}
