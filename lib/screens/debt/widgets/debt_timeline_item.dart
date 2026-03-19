import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mosa/models/debt.dart';
import 'package:mosa/models/transaction.dart';
import 'package:mosa/models/enums.dart';

class DebtTimelineItem extends StatelessWidget {
  final dynamic record; // Có thể là Debt (lúc tạo nợ) hoặc TransactionModel (lúc thanh toán)
  final bool isLent;

  const DebtTimelineItem({
    super.key,
    required this.record,
    required this.isLent,
  });

  @override
  Widget build(BuildContext context) {
    final isTransaction = record is TransactionModel;
    final DateTime date = isTransaction ? record.date : (record as Debt).createdDate;
    final double amount = isTransaction ? record.amount : (record as Debt).amount;
    
    IconData icon;
    Color iconColor;
    Color bgColor;
    String title;
    bool isMoneyIn = false;
    String sign = '';
    
    if (!isTransaction) {
      final debt = record as Debt;
      final bool isLentFromDebt = debt.type == DebtType.lent;
      icon = isLentFromDebt ? Icons.arrow_outward : Icons.south_west;
      iconColor = isLentFromDebt ? Colors.orange[700]! : Colors.purple[700]!;
      bgColor = isLentFromDebt ? Colors.orange[50]! : Colors.purple[50]!;
      title = isLentFromDebt ? 'Cho vay' : 'Đi vay';
      
      // Cho mượn (lent) là tiền ra (-), Đi mượn (borrowed) là tiền vào (+)
      isMoneyIn = debt.type == DebtType.borrowed;
    } else {
      final tx = record as TransactionModel;
      // Thu nợ (nhận tiền về) -> Mũi tên hướng vào
      // Trả nợ (tiền ra khỏi ví) -> Mũi tên hướng ra
      isMoneyIn = tx.type == TransactionType.debtCollection || tx.type == TransactionType.income || tx.type == TransactionType.borrowing;
      
      icon = isMoneyIn ? Icons.south_west : Icons.arrow_outward;
      iconColor = isMoneyIn ? Colors.green[700]! : Colors.blue[700]!;
      bgColor = isMoneyIn ? Colors.green[50]! : Colors.blue[50]!;
      title = tx.title.isNotEmpty ? tx.title : (isMoneyIn ? 'Đã thu nợ' : 'Đã trả nợ');
    }

    sign = isMoneyIn ? '+' : '-';

    final currencyFormat = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      sign + currencyFormat.format(amount),
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isMoneyIn ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  dateFormat.format(date),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                if (isTransaction && (record as TransactionModel).note != null && record.note!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    record.note!,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.outlineVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}
