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
    final flatCategories = await _databaseService.getAllCategories();
    return _buildTree(flatCategories);
  }

  /// Xây dựng cấu trúc cây từ danh mục phẳng lấy từ database
  List<Category> _buildTree(List<Category> flatCategories) {
    // Nhóm các danh mục theo parentId
    final Map<String?, List<Category>> childrenMap = {};
    for (var category in flatCategories) {
      childrenMap.putIfAbsent(category.parentId, () => []).add(category);
    }

    // Dựng cây phân cấp (hiện tại hỗ trợ 2 cấp: Cha -> Con)
    final List<Category> rootCategories = [];
    final parents = flatCategories.where((c) => c.parentId == null).toList();

    for (var parent in parents) {
      final children = childrenMap[parent.id] ?? [];
      rootCategories.add(parent.copyWith(children: children));
    }

    return rootCategories;
  }

  /// Làm mới danh sách danh mục từ database
  Future<void> refreshCategories() async {
    try {
      final flatCategories = await _databaseService.getAllCategories();
      final treeCategories = _buildTree(flatCategories);
      if (state.value != treeCategories) {
        state = AsyncData(treeCategories);
      }
    } catch (e, stack) {
      log('Refresh category error: ${e.toString()}', name: 'CategoriesNotifier', stackTrace: stack);
    }
  }

  /// Thêm danh mục mới
  Future<void> addCategory(Category category) async {
    try {
      await _databaseService.insertCategory(category);
      await refreshCategories();
    } catch (e, stackTrace) {
      log('Thêm danh mục thất bại: $e', name: 'CategoriesNotifier', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Cập nhật danh mục
  Future<void> updateCategory(Category category) async {
    try {
      await _databaseService.updateCategory(category);
      await refreshCategories();
    } catch (e, stackTrace) {
      log('Cập nhật danh mục thất bại: $e', name: 'CategoriesNotifier', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Xóa danh mục
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _databaseService.deleteCategory(categoryId);
      await refreshCategories();
    } catch (e, stackTrace) {
      log('Xóa danh mục thất bại: $e', name: 'CategoriesNotifier', stackTrace: stackTrace);
      rethrow;
    }
  }
}

/// Provider chính quản lý danh sách danh mục
final categoriesProvider = AsyncNotifierProvider(CategoriesNotifier.new);

/// Lấy danh sách danh mục theo loại
final categoryByTypeProvider = FutureProvider.family<List<Category>, String>((ref, categoryType) async {
  final categories = await ref.watch(categoriesProvider.future);
  return categories.where((element) => element.type == categoryType).toList();
});

/// Lấy danh sách danh mục phẳng (không có cây phân cấp)
final flattenedCategoryProvider = FutureProvider<List<Category>>((ref) async {
  final categories = await ref.watch(categoriesProvider.future);
  return TreeUtils.flatten(categories, (category) => category.children);
});

/// Lấy danh mục theo ID
final categoryByIdProvider = FutureProvider.family<Category?, String>((ref, categoryId) async {
  final categories = await ref.watch(flattenedCategoryProvider.future);
  return CollectionUtils.safeLookup(categories, (category) => category.id == categoryId);
});

/// Lấy danh mục theo tên
final categoryByNameProvider = FutureProvider.family<Category?, String>((ref, categoryName) async {
  final categories = await ref.watch(flattenedCategoryProvider.future);
  return CollectionUtils.safeLookup(categories, (category) => category.name == categoryName);
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
final selectedCategoryProvider = NotifierProvider<CategoryNotifier, Category?>(CategoryNotifier.new);

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
  final transactionType = getTransactionTypeFromCategory(selectCategory.id, selectCategory.name);

  // If it's unknown, fall back to the generic type mapping
  if (transactionType == TransactionType.unknown) {
    return getTransactionTypeFromString(selectCategory.type);
  }

  return transactionType;
});
