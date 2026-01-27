import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/models/debt.dart';
import 'package:mosa/models/enums.dart';
import 'package:mosa/providers/debt_provider.dart';
import 'package:mosa/providers/person_provider.dart';
import 'package:mosa/utils/app_colors.dart';
import 'package:mosa/utils/date_time_extension.dart';
import 'package:mosa/utils/helpers.dart';
import 'package:mosa/widgets/common_scaffold.dart';
import 'package:mosa/widgets/custom_list_tile.dart';

class DebtSelectionScreen extends ConsumerWidget {
  final DebtType debtType; // lent for collection, borrowed for repayment

  const DebtSelectionScreen({
    super.key,
    required this.debtType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtsAsync = ref.watch(debtProvider);

    return CommonScaffold(
      title: Text(debtType == DebtType.borrowed ? 'Chọn khoản nợ cần trả' : 'Chọn khoản nợ cần thu'),
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back),
      ),
      appBarBackgroundColor: AppColors.background,
      body: debtsAsync.when(
        data: (debts) {
          // Filter unpaid debts by type
          final filteredDebts = debts
              .where((debt) =>
                  debt.type == debtType &&
                  debt.status != DebtStatus.paid)
              .toList();

          if (filteredDebts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    debtType == DebtType.borrowed
                        ? 'Không có khoản nợ nào cần trả'
                        : 'Không có khoản nợ nào cần thu',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: filteredDebts.length,
            itemBuilder: (context, index) {
              final debt = filteredDebts[index];
              final person = ref.watch(personByIdProvider(debt.personId));

              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: CustomListTile(
                  leading: CircleAvatar(
                    child: person != null
                        ? Text(person.name.substring(0, 1).toUpperCase())
                        : Icon(Icons.person),
                  ),
                  title: Text(
                    person?.name ?? 'Unknown',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                  ),
                  subTitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(
                        debt.description,
                        style: TextStyle(fontSize: 13.sp),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Còn lại: ',
                            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                          ),
                          Text(
                            Helpers.formatCurrency(debt.remainingAmount),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.expense,
                            ),
                          ),
                        ],
                      ),
                      if (debt.dueDate != null) ...[
                        SizedBox(height: 2),
                        Text(
                          'Hạn: ${debt.dueDate!.ddMMyyy}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: debt.dueDate!.isBefore(DateTime.now())
                                ? Colors.red
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Helpers.formatCurrency(debt.amount),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Đã ${debtType == DebtType.borrowed ? "trả" : "thu"}: ${Helpers.formatCurrency(debt.paidAmount)}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Return selected debt to previous screen
                    context.pop(debt);
                  },
                  backgroundColor: Colors.transparent,
                ),
              );
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Lỗi: $error'),
        ),
      ),
    );
  }
}
