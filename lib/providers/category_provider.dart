import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mosa/models/category.dart';
import 'package:mosa/models/enums.dart';
import 'package:mosa/providers/database_service_provider.dart';
import 'package:mosa/services/database_service.dart';
import 'package:mosa/utils/collection_utils.dart';
import 'package:mosa/utils/tree_utils.dart';

import '../utils/utils.dart';

/// Quản lý trạng thái danh sách danh mục
class CategoriesNotifier extends AsyncNotifier<List<Category>> {
  DatabaseService get _databaseService => ref.read(databaseServiceProvider);

  @override
  FutureOr<List<Category>> build() async {
    return await _databaseService.getAllCategories();
  }

  /// Làm mới danh sách danh mục từ database
  Future<void> refreshCategories() async {
    try {
      final categories = await _databaseService.getAllCategories();
      if (state.value != categories) {
        state = AsyncData(categories);
      }
    } catch (e) {
      log('Refresh category in background have error ${e.toString()}');
    }
  }
}

/// Provider chính quản lý danh sách danh mục
final categoriesProvider = AsyncNotifierProvider(CategoriesNotifier.new);

/// Lấy danh sách danh mục theo loại
final categoryByTypeProvider = FutureProvider.family<List<Category>, String>((
  ref,
  categoryType,
) async {
  final categories = await ref.watch(categoriesProvider.future);
  return categories.where((element) => element.type == categoryType).toList();
});

/// Lấy danh sách danh mục phẳng (không có cây phân cấp)
final flattenedCategoryProvider = FutureProvider<List<Category>>((ref) async {
  final categories = await ref.watch(categoriesProvider.future);
  return TreeUtils.flatten(categories, (category) => category.children);
});

/// Lấy danh mục theo ID
final categoryByIdProvider = FutureProvider.family<Category?, String>((
  ref,
  categoryId,
) async {
  final categories = await ref.watch(flattenedCategoryProvider.future);
  return CollectionUtils.safeLookup(
    categories,
    (category) => category.id == categoryId,
  );
});

/// Lấy danh mục theo tên
final categoryByNameProvider = FutureProvider.family<Category?, String>((
  ref,
  categoryName,
) async {
  final categories = await ref.watch(flattenedCategoryProvider.future);
  return CollectionUtils.safeLookup(
    categories,
    (category) => category.name == categoryName,
  );
});

/// Quản lý trạng thái danh mục được chọn
class CategoryNotifier extends Notifier<Category?> {
  @override
  Category? build() => null;

  void selectCategory(Category? category) {
    state = category;
    log('state: ${state?.name}');
  }
}

/// Provider lưu trữ danh mục được chọn
final selectedCategoryProvider = NotifierProvider<CategoryNotifier, Category?>(
  CategoryNotifier.new,
);

/// Map danh mục theo ID để tra cứu O(1)
final categoryMapProvider = FutureProvider<Map<String, Category>>((ref) async {
  final categories = await ref.watch(flattenedCategoryProvider.future);
  return {for (var category in categories) category.id: category};
});

/// Tự động xác định loại giao dịch dựa trên danh mục được chọn
final autoTransactionTypeProvider = StateProvider<TransactionType?>((ref) {
  final selectCategory = ref.watch(selectedCategoryProvider);
  if (selectCategory == null) return null;

  // First try to get transaction type from category ID/name (handles special cases like lending)
  final transactionType = getTransactionTypeFromCategory(
    selectCategory.id,
    selectCategory.name,
  );

  // If it's unknown, fall back to the generic type mapping
  if (transactionType == TransactionType.unknown) {
    return getTransactionTypeFromString(selectCategory.type);
  }

  return transactionType;
});
