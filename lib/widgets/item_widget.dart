import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mosa/models/category.dart';

/// Widget hiển thị một mục (item) dưới dạng icon và nhãn văn bản bên dưới.
///
/// [ItemWidget] hỗ trợ 3 cách khởi tạo chính để làm nổi bật nguồn dữ liệu icon:
/// 1. [ItemWidget.category]: Khởi tạo từ đối tượng [Category].
/// 2. [ItemWidget.iconPath]: Khởi tạo từ đường dẫn ảnh assets.
/// 3. [ItemWidget.icon]: Khởi tạo từ [IconData] (Material Icons).
class ItemWidget extends ConsumerWidget {
  /// Đối tượng danh mục (nếu có)
  final Category? category;

  /// Tên hiển thị của mục
  final String? name;

  /// Đường dẫn đến file ảnh icon trong assets
  final String? iconPath;

  /// Dữ liệu icon từ thư viện Material Icons
  final IconData? icon;

  /// Hàm xử lý khi người dùng nhấn vào mục
  final void Function()? onTap;

  /// Căn chỉnh các thành phần theo trục ngang (mặc định là center)
  final CrossAxisAlignment? crossAxisAlignment;

  /// ID định danh của mục (tùy chọn)
  final String? itemId;

  /// Constructor mặc định (Private) - Khuyến khích sử dụng các named constructors bên dưới.
  const ItemWidget._({
    super.key,
    this.category,
    this.name,
    this.iconPath,
    this.icon,
    this.onTap,
    this.crossAxisAlignment,
    this.itemId,
  });

  /// 🌟 **Option 1: Khởi tạo từ Category**
  ///
  /// Sử dụng khi bạn đã có một đối tượng [Category] từ database hoặc cung cấp sẵn.
  /// Icon và tên sẽ được lấy tự động từ [category].
  factory ItemWidget.category({
    Key? key,
    required Category category,
    void Function()? onTap,
    CrossAxisAlignment? crossAxisAlignment,
  }) {
    return ItemWidget._(
      key: key,
      category: category,
      onTap: onTap,
      crossAxisAlignment: crossAxisAlignment,
    );
  }

  /// 🌟 **Option 2: Khởi tạo từ đường dẫn ảnh Assets**
  ///
  /// Sử dụng khi bạn muốn hiển thị một icon tùy chỉnh từ thư mục assets.
  /// Cần cung cấp [iconPath] và [name] hiển thị.
  factory ItemWidget.iconPath({
    Key? key,
    required String iconPath,
    required String name,
    String? itemId,
    void Function()? onTap,
    CrossAxisAlignment? crossAxisAlignment,
  }) {
    return ItemWidget._(
      key: key,
      iconPath: iconPath,
      name: name,
      itemId: itemId,
      onTap: onTap,
      crossAxisAlignment: crossAxisAlignment,
    );
  }

  /// 🌟 **Option 3: Khởi tạo từ IconData (Material Icons)**
  ///
  /// Sử dụng khi bạn muốn dùng các icon hệ thống có sẵn của Flutter.
  /// Cần cung cấp [icon] và [name] hiển thị.
  factory ItemWidget.icon({
    Key? key,
    required IconData icon,
    required String name,
    String? itemId,
    void Function()? onTap,
    CrossAxisAlignment? crossAxisAlignment,
  }) {
    return ItemWidget._(
      key: key,
      icon: icon,
      name: name,
      itemId: itemId,
      onTap: onTap,
      crossAxisAlignment: crossAxisAlignment,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3), width: 1),
            ),
            child: _buildIcon(colorScheme),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              category?.name ?? name ?? '',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colorScheme.onSurface, height: 1.2),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(ColorScheme colorScheme) {
    if (icon != null) {
      return Icon(icon, color: colorScheme.primary, size: 28);
    }

    if (category != null) {
      return category!.getIcon();
    }

    return Image.asset(
      iconPath ?? 'assets/icons/default.png',
      width: 28,
      height: 28,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.category_outlined, color: colorScheme.primary);
      },
    );
  }
}
