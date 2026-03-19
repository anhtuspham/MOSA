import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/models/budget.dart';
import 'package:mosa/models/category.dart';
import 'package:mosa/models/enums.dart';
import 'package:mosa/providers/budget_provider.dart';
import 'package:mosa/providers/transaction_provider.dart';
import 'package:mosa/config/app_colors.dart';
import 'package:mosa/utils/number_input_formatter.dart';
import 'package:mosa/widgets/common_scaffold.dart';
import 'package:mosa/utils/toast.dart';

class AddBudgetScreen extends ConsumerStatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  ConsumerState<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends ConsumerState<AddBudgetScreen> {
  Category? _selectedCategory;
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _saveBudget() async {
    if (_selectedCategory == null) {
      showResultToast('Vui lòng chọn danh mục', isError: true);
      return;
    }

    final amountText = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (amountText.isEmpty) {
      showResultToast('Vui lòng nhập số tiền', isError: true);
      return;
    }

    final amount = double.parse(amountText);
    if (amount <= 0) {
      showResultToast('Số tiền phải lớn hơn 0', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final date = ref.read(budgetDateFilterProvider);
      final budget = Budget(categoryId: _selectedCategory!.id, amount: amount, month: date.month, year: date.year);

      await ref.read(budgetProvider.notifier).upsertBudget(budget);

      if (mounted) {
        context.pop();
        showResultToast('Lưu ngân sách thành công');
      }
    } catch (e) {
      if (mounted) {
        showResultToast('Lỗi: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CommonScaffold.single(
      title: const Text('Thêm Ngân Sách', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      appBarBackgroundColor: colorScheme.onPrimaryFixedVariant,
      elevation: false,
      leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            InkWell(
              onTap: () async {
                ref.read(activeTransactionTypeProvider.notifier).state = TransactionType.income;
                // Navigate to select category screen, expecting string result back
                // This will use the existing route 'categoryList' configured to return a Category
                final category = await context.pushNamed('categoryList');
                if (category != null && category is Category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Icon(
                      _selectedCategory == null ? Icons.category_outlined : Icons.category,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _selectedCategory?.name ?? 'Chọn Danh Mục',
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              _selectedCategory == null
                                  ? Theme.of(context).colorScheme.onSurfaceVariant
                                  : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(Icons.monetization_on_outlined, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [NumberInputFormatter()],
                      decoration: const InputDecoration(
                        hintText: 'Nhập số tiền ngân sách',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Text('đ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _isLoading ? null : _saveBudget,
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                        : const Text(
                          'Lưu',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
