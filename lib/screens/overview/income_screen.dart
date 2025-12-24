import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosa/models/enums.dart';
import 'package:mosa/utils/helpers.dart';
import 'package:mosa/utils/toast.dart';
import 'package:mosa/widgets/error_widget.dart';
import 'package:mosa/widgets/loading_widget.dart';
import 'package:mosa/widgets/progress_info_item.dart';

import '../../providers/transaction_provider.dart';
import '../../widgets/category_pie_chart.dart';

class IncomeScreen extends ConsumerStatefulWidget {
  const IncomeScreen({super.key});

  @override
  ConsumerState<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends ConsumerState<IncomeScreen> {
  @override
  Widget build(BuildContext context) {
    final totalIncome = ref.watch(totalIncomeProvider);
    final transactionByTypeController = ref.watch(enrichedTransactionByTypeProvider(TransactionType.income));

    return RefreshIndicator(
      onRefresh: _handleOnRefresh,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: Colors.white),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('Tổng thu'), Text(Helpers.formatCurrency(totalIncome), style: TextStyle(fontWeight: FontWeight.bold))],
              ),
            ),
            CategoryPieChart(categoryData: {'Ăn uống': 300000, 'Xe cộ': 900000, 'Đi chơi': 900000, 'Mua sắm': 980000, 'Khác': 900000}),
            transactionByTypeController.when(
              data: (transactionData) {
                return Column(
                  children:
                      transactionData.map((transactionTypeValue) {
                        final totalValue = ref.watch(totalAmountByCategoryProvider(transactionTypeValue.category?.id ?? ''));
                        return ProgressInfoItem(
                          leadingIcon: transactionTypeValue.category?.getIcon() ?? Icon(Icons.help),
                          title: Text(transactionTypeValue.category?.name ?? ''),
                          currentProgress: 0.2,
                          trailing: Row(
                            children: [
                              Text('(32.39%)', style: TextStyle(color: Colors.grey[500], fontSize: 11.sp)),
                              const SizedBox(width: 3),
                              Text(Helpers.formatCurrency(totalValue), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                            ],
                          )
                        );
                      }).toList(),
                );
              },
              error: (error, stackTrace) => ErrorSectionWidget(error: error),
              loading: () => LoadingSectionWidget(),
            ),
            ProgressInfoItem(
              leadingIcon: Icon(Icons.calendar_month),
              title: Text('Điều chỉnh số dư'),
              currentProgress: 0.2,
              trailing: Row(
                children: [
                  Text('(32.39%)', style: TextStyle(color: Colors.grey[500], fontSize: 11.sp)),
                  const SizedBox(width: 3),
                  Text('117.167 đ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                ],
              ),
            ),
            ProgressInfoItem(
              leadingIcon: Icon(Icons.calendar_month),
              title: Text('Điều chỉnh số dư'),
              currentProgress: 0.2,
              trailing: Row(
                children: [
                  Text('(32.39%)', style: TextStyle(color: Colors.grey[500], fontSize: 11.sp)),
                  const SizedBox(width: 3),
                  Text('117.167 đ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                ],
              ),
            ),
            ProgressInfoItem(
              leadingIcon: Icon(Icons.calendar_month),
              title: Text('Điều chỉnh số dư'),
              currentProgress: 0.2,
              trailing: Row(
                children: [
                  Text('(32.39%)', style: TextStyle(color: Colors.grey[500], fontSize: 11.sp)),
                  const SizedBox(width: 3),
                  Text('117.167 đ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleOnRefresh() async {
    try {
      ref.invalidate(totalIncomeProvider);
    } catch (e) {
      showToast('Lỗi khi tải trang', isError: true);
    }
  }
}
