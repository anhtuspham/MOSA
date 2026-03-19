import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mosa/models/debt.dart';
import 'package:mosa/models/person.dart';
import 'package:mosa/models/transaction.dart';
import 'package:mosa/providers/debt_history_provider.dart';
import 'package:mosa/providers/debt_provider.dart';
import 'package:mosa/providers/person_provider.dart';
import 'package:mosa/screens/debt/widgets/debt_bottom_sheet.dart';
import 'package:mosa/screens/debt/widgets/debt_item_card.dart';
import 'package:mosa/screens/debt/widgets/debt_timeline_item.dart';
import 'package:mosa/widgets/common_scaffold.dart';

class PersonDebtDetailScreen extends ConsumerStatefulWidget {
  final int personId;
  const PersonDebtDetailScreen({super.key, required this.personId});

  @override
  ConsumerState<PersonDebtDetailScreen> createState() => _PersonDebtDetailScreenState();
}

class _PersonDebtDetailScreenState extends ConsumerState<PersonDebtDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final personAsync = ref.watch(personProvider);
    Person? person;
    if (personAsync.value != null) {
      person = personAsync.value!.firstWhere(
        (p) => p.id == widget.personId,
        orElse: () => Person(name: 'Unknown', id: widget.personId),
      );
    }

    final debts = ref.watch(debtByPersonProvider(widget.personId));
    final timelineAsync = ref.watch(personDebtTimelineProvider(widget.personId));

    double totalLentRemaining = 0;
    double totalBorrowedRemaining = 0;
    bool hasOverdue = false;

    for (var d in debts) {
      if (d.status != DebtStatus.paid) {
        if (d.type == DebtType.lent) {
          totalLentRemaining += d.remainingAmount;
        } else {
          totalBorrowedRemaining += d.remainingAmount;
        }

        if (d.dueDate != null && d.dueDate!.isBefore(DateTime.now())) {
          hasOverdue = true;
        }
      }
    }

    final netBalance = totalLentRemaining - totalBorrowedRemaining;
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

    return CommonScaffold.single(
      title: const Text('Chi tiết đối tác'),
      body: Column(
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      // backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Text(
                        person?.name != null && person!.name.isNotEmpty
                            ? person.name.substring(0, 1).toUpperCase()
                            : '?',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                person?.name ?? 'Unknown',
                                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              if (hasOverdue) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.red[200]!),
                                  ),
                                  child: Text(
                                    'Quá hạn',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: Colors.red[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('Đối tác', style: GoogleFonts.inter(fontSize: 14, color: Theme.of(context).colorScheme.outlineVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Summary Block
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trạng thái nợ',
                            style: GoogleFonts.inter(fontSize: 13, color: Theme.of(context).hintColor),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            netBalance == 0
                                ? 'Đã thanh toán hết'
                                : (netBalance > 0 ? 'Người này nợ bạn' : 'Bạn nợ người này'),
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color:
                                  netBalance == 0
                                      ? Colors.green[700]
                                      : (netBalance > 0 ? Colors.green[700] : Colors.red[700]),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        currencyFormat.format(netBalance.abs()),
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color:
                              netBalance == 0
                                  ? Colors.green[700]
                                  : (netBalance > 0 ? Colors.green[700] : Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tabs
          TabBar(
            controller: _tabController,
            labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
            unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.normal),
            tabs: const [Tab(text: 'Danh sách nợ'), Tab(text: 'Lịch sử')],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Danh sách DebtItemCard
                debts.isEmpty
                    ? const Center(child: Text('Chưa có khoản nợ nào.'))
                    : ListView.builder(
                      itemCount: debts.length,
                      itemBuilder: (context, index) {
                        final debt = debts[index];
                        return DebtItemCard(
                          debt: debt,
                          onTap: () {
                            ref.read(selectedDebtProvider.notifier).state = debt;
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (_) => const DebtBottomSheet(),
                            );
                          },
                        );
                      },
                    ),

                // Tab 2: Lịch sử Timeline
                timelineAsync.when(
                  data: (timeline) {
                    if (timeline.isEmpty) {
                      return const Center(child: Text('Chưa có lịch sử giao dịch.'));
                    }
                    return ListView.builder(
                      itemCount: timeline.length,
                      itemBuilder: (context, index) {
                        final record = timeline[index];
                        bool isLentContent = true;

                        if (record is Debt) {
                          isLentContent = record.type == DebtType.lent;
                        } else if (record is TransactionModel) {
                          final parentDebt = debts.firstWhere(
                            (d) => d.id == record.debtId,
                            orElse:
                                () =>
                                    debts.isNotEmpty
                                        ? debts.first
                                        : Debt(
                                          personId: 0,
                                          amount: 0,
                                          type: DebtType.lent,
                                          status: DebtStatus.active,
                                          createdDate: DateTime.now(),
                                          description: 'Unknown',
                                          walletId: 0,
                                        ),
                          );
                          isLentContent = parentDebt.type == DebtType.lent;
                        }

                        return DebtTimelineItem(record: record, isLent: isLentContent);
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text('Lỗi: $e')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
