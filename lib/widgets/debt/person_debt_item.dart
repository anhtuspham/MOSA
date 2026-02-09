import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosa/providers/debt_provider.dart';
import 'package:mosa/providers/person_provider.dart';
import 'package:mosa/utils/app_colors.dart';
import 'package:mosa/utils/helpers.dart';
import 'package:mosa/widgets/custom_list_tile.dart';

class PersonDebtItem extends ConsumerWidget {
  final bool isLent;
  final int personId;
  final VoidCallback? handleShowBottomSheet;
  final VoidCallback? onTap;
  const PersonDebtItem({super.key, required this.isLent, required this.personId, this.handleShowBottomSheet, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final person = ref.watch(personByIdProvider(personId));
    final debtLent = ref.watch(totalDebtLentByPersonProvider(personId));
    final debtBorrowed = ref.watch(totalDebtBorrowedByPersonProvider(personId));

    final debt = isLent ? debtLent : debtBorrowed;

    return CustomListTile(
      leading: CircleAvatar(child: Text(person?.name.substring(0, 1).toUpperCase() ?? 'T')),
      title: Text(person?.name ?? 'Unknown', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp)),
      trailing: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              handleShowBottomSheet != null
                  ? Text(
                    Helpers.formatCurrency(debt.totalDebt),
                    style: TextStyle(fontSize: 16.sp, color: AppColors.textPrimary),
                  )
                  : const SizedBox(),
              Text(
                Helpers.formatCurrency(debt.totalDebtRemaining),
                style: TextStyle(fontSize: 15.sp, color: AppColors.expense),
              ),
            ],
          ),
          handleShowBottomSheet != null
              ? IconButton(
                onPressed: () => handleShowBottomSheet?.call(),
                icon: Icon(Icons.more_vert, color: AppColors.textPrimary),
              )
              : const SizedBox(),
        ],
      ),
      onTap: () => onTap?.call(),
    );
  }
}
