import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mosa/models/debt.dart';

class DebtItemCard extends StatelessWidget {
  final Debt debt;
  final VoidCallback? onTap;

  const DebtItemCard({
    super.key,
    required this.debt,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd/MM/yyyy');

    final remainingAmount = debt.amount - debt.paidAmount;
    final progress = debt.amount > 0 ? (debt.paidAmount / debt.amount) : 0.0;
    
    // Check if overdue
    final isOverdue = debt.status != DebtStatus.paid &&
        debt.dueDate != null &&
        debt.dueDate!.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isOverdue ? Colors.red.withOpacity(0.5) : Colors.grey.withOpacity(0.2),
          width: isOverdue ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      debt.description.isNotEmpty ? debt.description : (debt.type == DebtType.lent ? 'Khoản cho vay' : 'Khoản đi vay'),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusBadge(isOverdue),
                ],
              ),
              const SizedBox(height: 12),
              
              // Amounts row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tổng cộng',
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        currencyFormat.format(debt.amount),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Còn lại',
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        currencyFormat.format(remainingAmount),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: debt.type == DebtType.lent ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    debt.status == DebtStatus.paid ? Colors.green : Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              // Dates
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ngày tạo: ${dateFormat.format(debt.createdDate)}',
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500]),
                  ),
                  if (debt.dueDate != null)
                    Text(
                      'Hạn trả: ${dateFormat.format(debt.dueDate!)}',
                      style: GoogleFonts.inter(
                        fontSize: 11, 
                        color: isOverdue ? Colors.red : Colors.grey[500],
                        fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isOverdue) {
    Color bgColor;
    Color textColor;
    String text;

    if (isOverdue) {
      bgColor = Colors.red[50]!;
      textColor = Colors.red[700]!;
      text = 'Quá hạn';
    } else {
      switch (debt.status) {
        case DebtStatus.active:
          bgColor = Colors.amber[50]!;
          textColor = Colors.amber[800]!;
          text = 'Đang vay';
          break;
        case DebtStatus.partial:
          bgColor = Colors.blue[50]!;
          textColor = Colors.blue[700]!;
          text = 'Đã trả một phần';
          break;
        case DebtStatus.paid:
          bgColor = Colors.green[50]!;
          textColor = Colors.green[700]!;
          text = 'Đã thanh toán';
          break;
        default:
          bgColor = Colors.grey[100]!;
          textColor = Colors.grey[700]!;
          text = 'Không rõ';
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
