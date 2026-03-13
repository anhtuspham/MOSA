import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mosa/models/category.dart';
import 'package:mosa/providers/category_provider.dart';
import 'package:mosa/utils/toast.dart';

class CategoryFormBottomSheet extends ConsumerStatefulWidget {
  final Category? category;
  final String initialType;

  const CategoryFormBottomSheet({
    super.key,
    this.category,
    required this.initialType,
  });

  @override
  ConsumerState<CategoryFormBottomSheet> createState() => _CategoryFormBottomSheetState();
}

class _CategoryFormBottomSheetState extends ConsumerState<CategoryFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late String _selectedType;
  String _selectedIcon = 'attach_money';
  bool _isLoading = false;

  final List<String> _availableIcons = [
    'attach_money', 'more_horiz', 'card_giftcard', 'monetization_on', 'trending_up',
    'restaurant', 'breakfast_dining', 'lunch_dining', 'dinner_dining',
    'shopping_cart', 'checkroom', 'devices', 'shopping_bag',
    'movie', 'directions_car', 'local_taxi', 'directions_bus', 'two_wheeler',
    'receipt', 'health_and_safety', 'school', 'flight', 'home', 'local_cafe',
    'handshake', 'gavel', 'check_circle', 'paid', 'autorenew'
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.category?.type ?? widget.initialType;
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      if (widget.category!.iconType == 'material') {
        _selectedIcon = widget.category!.iconPath;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      if (widget.category == null) {
        // Create new
        final newCategory = Category(
          id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
          name: _nameController.text.trim(),
          type: _selectedType,
          iconType: 'material',
          iconPath: _selectedIcon,
        );
        await ref.read(categoriesProvider.notifier).addCategory(newCategory);
        showResultToast('Đã thêm hạng mục mới');
      } else {
        // Update
        final updatedCategory = widget.category!.copyWith(
          name: _nameController.text.trim(),
          type: _selectedType,
          iconType: 'material',
          iconPath: _selectedIcon,
        );
        await ref.read(categoriesProvider.notifier).updateCategory(updatedCategory);
        showResultToast('Đã cập nhật hạng mục');
      }
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      showResultToast(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: bottomInset > 0 ? bottomInset + 16 : 32,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.category == null ? 'Thêm hạng mục mới' : 'Chỉnh sửa hạng mục',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên hạng mục',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên hạng mục';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Phân loại',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'income', child: Text('Thu nhập')),
                DropdownMenuItem(value: 'expense', child: Text('Chi tiêu')),
                DropdownMenuItem(value: 'other', child: Text('Khác')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedType = value);
                }
              },
            ),
            const SizedBox(height: 16),
            const Text('Chọn biểu tượng', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            SizedBox(
              height: 150,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _availableIcons.length,
                itemBuilder: (context, index) {
                  final iconName = _availableIcons[index];
                  // Lấy placeholder Category để lấy icon
                  final tempCategory = Category.empty().copyWith(
                    iconType: 'material',
                    iconPath: iconName,
                  );
                  final isSelected = _selectedIcon == iconName;
                  
                  return InkWell(
                    onTap: () => setState(() => _selectedIcon = iconName),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.2) : Colors.transparent,
                        border: isSelected ? Border.all(color: Theme.of(context).primaryColor, width: 2) : Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: tempCategory.getIcon(size: 24),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                : const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }
}
