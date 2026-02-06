
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mosa/utils/helpers.dart';
import 'package:mosa/screens/overview/widgets/transaction_item.dart';

import '../../../models/category.dart';
import '../../../models/enums.dart';
import '../../../providers/date_filter_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../utils/date_time_extension.dart';
import '../../../utils/utils.dart';

/// Ghi chép thu chi trong 1 đơn vị thời gian
class TransactionInPeriodTime extends ConsumerStatefulWidget {
  final String typeDate;
  final DateTime date;

  const TransactionInPeriodTime({
    super.key,
    this.typeDate = 'day',
    required this.date,
  });

  @override
  ConsumerState<TransactionInPeriodTime> createState() =>
      _TransactionInPeriodTimeState();
}

class _TransactionInPeriodTimeState
    extends ConsumerState<TransactionInPeriodTime> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        children: [
          dateHeaderSection(),
          const SizedBox(height: 8),
          transactionListSection(),
        ],
      ),
    );
  }

  Widget dateHeaderSection() {
    final totalState = ref.watch(totalByDateProvider(widget.date));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              convertDateTimeToString(widget.date),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(widget.date.weekdayLabel),
          ],
        ),
        totalState.when(
          data:
              (totalData) => Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (totalData.income > 0)
                    Text(
                      Helpers.formatCurrency(totalData.income),
                      style: TextStyle(
                        color: getTransactionTypeColor(
                          type: TransactionType.income,
                        ),
                        fontSize: 14,
                      ),
                    ),
                  if (totalData.expense > 0)
                    Text(
                      Helpers.formatCurrency(totalData.expense),
                      style: TextStyle(
                        color: getTransactionTypeColor(
                          type: TransactionType.expense,
                        ),
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
          loading: () => CircularProgressIndicator(),
          error: (_, _) => Center(child: Text('Error')),
        ),
      ],
    );
  }

  Widget transactionListSection() {
    final enrichedTransactionGroupState = ref.watch(enrichedTransactionGroupByDateProvider);
    final enrichedTransactionOfDay = enrichedTransactionGroupState.whenData(
      (group) => group[widget.date] ?? [],
    );

    return enrichedTransactionOfDay.when(
      data: (enrichedData) {
        return ListView.builder(
          itemCount: enrichedData.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final item = enrichedData[index];
            return TransactionItem(
              category: item.category ?? Category.empty(),
              transaction: item.transaction,
            );
          },
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
    );
  }
}
