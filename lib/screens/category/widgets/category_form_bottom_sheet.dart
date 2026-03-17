import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mosa/models/category.dart';
import 'package:mosa/providers/category_provider.dart';
import 'package:mosa/utils/toast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class CategoryFormBottomSheet extends ConsumerStatefulWidget {
  final Category? category;
  final String initialType;

  const CategoryFormBottomSheet({super.key, this.category, required this.initialType});

  @override
  ConsumerState<CategoryFormBottomSheet> createState() => _CategoryFormBottomSheetState();
}

class _CategoryFormBottomSheetState extends ConsumerState<CategoryFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late String _selectedType;
  String? _selectedParentId;
  String _selectedIcon = 'attach_money';
  String _selectedIconType = 'material';
  bool _isLoading = false;
  List<String> _customIcons = [];

  final List<String> _availableIcons = [
    'attach_money',
    'more_horiz',
    'card_giftcard',
    'monetization_on',
    'trending_up',
    'restaurant',
    'breakfast_dining',
    'lunch_dining',
    'dinner_dining',
    'shopping_cart',
    'checkroom',
    'devices',
    'shopping_bag',
    'movie',
    'directions_car',
    'local_taxi',
    'directions_bus',
    'two_wheeler',
    'receipt',
    'health_and_safety',
    'school',
    'flight',
    'home',
    'local_cafe',
    'handshake',
    'gavel',
    'check_circle',
    'paid',
    'autorenew',
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.category?.type ?? widget.initialType;
    _selectedParentId = widget.category?.parentId;
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _selectedIconType = widget.category!.iconType;
      _selectedIcon = widget.category!.iconPath;
    }
    _loadCustomIcons();
  }

  Future<void> _loadCustomIcons() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _customIcons = prefs.getStringList('category_custom_icons') ?? [];
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        // Lấy thư mục app document để lưu trữ vĩnh viễn
        final directory = await getApplicationDocumentsDirectory();

        // Tạo thư mục custom_icons nếu chưa có
        final customIconsDir = Directory('${directory.path}/custom_icons');
        if (!await customIconsDir.exists()) {
          await customIconsDir.create(recursive: true);
        }

        // Tạo tên file mới dựa trên timestamp để tránh trùng lặp
        final fileName = 'cat_icon_${DateTime.now().millisecondsSinceEpoch}${path.extension(pickedFile.path)}';
        final savedFile = await File(pickedFile.path).copy('${customIconsDir.path}/$fileName');

        final savedPath = savedFile.path;

        setState(() {
          if (!_customIcons.contains(savedPath)) {
            _customIcons.insert(0, savedPath); // Thêm vào đầu danh sách
          }
          _selectedIcon = savedPath;
          _selectedIconType = 'local_file';
        });

        // Lưu lại danh sách vào SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('category_custom_icons', _customIcons);
      }
    } catch (e) {
      showResultToast('Lỗi khi tải ảnh: $e', isError: true);
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Chọn từ thư viện'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Chụp ảnh mới'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
    );
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
          iconType: _selectedIconType,
          iconPath: _selectedIcon,
          parentId: _selectedParentId,
        );
        await ref.read(categoriesProvider.notifier).addCategory(newCategory);
        showResultToast('Đã thêm hạng mục mới');
      } else {
        // Update
        final updatedCategory = widget.category!.copyWith(
          name: _nameController.text.trim(),
          type: _selectedType,
          iconType: _selectedIconType,
          iconPath: _selectedIcon,
          parentId: _selectedParentId,
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
      padding: EdgeInsets.only(left: 16, right: 16, top: 24, bottom: bottomInset > 0 ? bottomInset + 16 : 32),
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
              decoration: const InputDecoration(labelText: 'Tên hạng mục', border: OutlineInputBorder()),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên hạng mục';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              decoration: const InputDecoration(labelText: 'Phân loại', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'income', child: Text('Thu nhập')),
                DropdownMenuItem(value: 'expense', child: Text('Chi tiêu')),
                DropdownMenuItem(value: 'other', child: Text('Khác')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                    _selectedParentId = null; // Reset parentId when type changes
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, child) {
                final categoriesAsync = ref.watch(categoryByTypeProvider(_selectedType));

                return categoriesAsync.when(
                  data: (categories) {
                    // Chỉ lấy các hạng mục cha (không có parentId)
                    // Và không bao gồm chính nó nếu đang sửa
                    final parentCategories =
                        categories.where((c) {
                          final isNotSelf = widget.category == null || c.id != widget.category!.id;
                          final isRoot = c.parentId == null;
                          return isNotSelf && isRoot;
                        }).toList();

                    return DropdownButtonFormField<String?>(
                      initialValue: _selectedParentId,
                      decoration: const InputDecoration(
                        labelText: 'Hạng mục cha',
                        border: OutlineInputBorder(),
                        hintText: 'Chọn hạng mục cha (không bắt buộc)',
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Không có (Hạng mục gốc)')),
                        ...parentCategories.map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Row(children: [c.getIcon(size: 20), const SizedBox(width: 8), Text(c.name)]),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedParentId = value);
                      },
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (err, stack) => Text('Lỗi tải hạng mục cha: $err'),
                );
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
                itemCount: 1 + _customIcons.length + _availableIcons.length,
                itemBuilder: (context, index) {
                  // Nút thứ nhất: Thêm ảnh
                  if (index == 0) {
                    return InkWell(
                      onTap: _showImagePickerOptions,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          border: Border.all(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                            width: 1.5,
                            strokeAlign: BorderSide.strokeAlignInside,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.add_photo_alternate,
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.8),
                        ),
                      ),
                    );
                  }

                  // Các custom icons (Ảnh từ thiết bị) hiện tiếp theo
                  if (index <= _customIcons.length) {
                    final customIconIndex = index - 1;
                    final iconPath = _customIcons[customIconIndex];
                    final isSelected = _selectedIcon == iconPath && _selectedIconType == 'local_file';

                    return InkWell(
                      onTap:
                          () => setState(() {
                            _selectedIcon = iconPath;
                            _selectedIconType = 'local_file';
                          }),
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.2) : Colors.transparent,
                          border:
                              isSelected
                                  ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                                  : Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Image.file(File(iconPath), fit: BoxFit.cover),
                      ),
                    );
                  }

                  // Các Material Icons hiển thị cuối cùng
                  final materialIconIndex = index - 1 - _customIcons.length;
                  final iconName = _availableIcons[materialIconIndex];

                  // Lấy placeholder Category để lấy icon
                  final tempCategory = Category.empty().copyWith(iconType: 'material', iconPath: iconName);
                  final isSelected = _selectedIcon == iconName && _selectedIconType == 'material';

                  return InkWell(
                    onTap:
                        () => setState(() {
                          _selectedIcon = iconName;
                          _selectedIconType = 'material';
                        }),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.2) : Colors.transparent,
                        border:
                            isSelected
                                ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                                : Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(child: tempCategory.getIcon(size: 24)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isLoading ? null : _submit,
              child:
                  _isLoading
                      ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                      : const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }
}
