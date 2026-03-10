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
    
    if (!isTransaction) {
      icon = isLent ? Icons.arrow_outward : Icons.south_west;
      iconColor = isLent ? Colors.orange[700]! : Colors.purple[700]!;
      bgColor = isLent ? Colors.orange[50]! : Colors.purple[50]!;
      title = isLent ? 'Cho vay mới' : 'Đi vay mới';
    } else {
      final tx = record as TransactionModel;
      final isCollection = tx.type == TransactionType.debtCollection;
      // Thu nợ (nhận tiền về) -> Mũi tên hướng vào
      // Trả nợ (tiền ra khỏi ví) -> Mũi tên hướng ra
      icon = isCollection ? Icons.south_west : Icons.arrow_outward;
      iconColor = isCollection ? Colors.green[700]! : Colors.blue[700]!;
      bgColor = isCollection ? Colors.green[50]! : Colors.blue[50]!;
      title = tx.title.isNotEmpty ? tx.title : (isCollection ? 'Đã thu nợ' : 'Đã trả nợ');
    }

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
                      (!isTransaction ? '+' : '-') + currencyFormat.format(amount),
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: !isTransaction ? iconColor : Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  dateFormat.format(date),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),
                if (isTransaction && (record as TransactionModel).note != null && record.note!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    record.note!,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey[700],
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
