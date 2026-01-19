import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mosa/models/category.dart';
import 'package:mosa/providers/database_service_provider.dart';
import 'package:mosa/services/database_service.dart';
import 'package:mosa/utils/collection_utils.dart';
import 'package:mosa/utils/tree_utils.dart';

// final categoriesProvider = FutureProvider<List<Category>>((ref) {
//   return CategoryService.loadCategories();
// });

class CategoriesNotifier extends AsyncNotifier<List<Category>> {
  DatabaseService get _databaseService => ref.read(databaseServiceProvider);

  @override
  FutureOr<List<Category>> build() async {
    return await _databaseService.getAllCategories();
  }

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

final categoriesProvider = AsyncNotifierProvider(CategoriesNotifier.new);

final categoryByTypeProvider = FutureProvider.family<List<Category>, String>((ref, categoryType) async {
  final categories = await ref.watch(categoriesProvider.future);
  return categories.where((element) => element.type == categoryType).toList();
});

final flattenedCategoryProvider = FutureProvider<List<Category>>((ref) async {
  final categories = await ref.watch(categoriesProvider.future);
  return TreeUtils.flatten(categories, (category) => category.children);
});

final categoryByIdProvider = FutureProvider.family<Category?, String>((ref, categoryId) async {
  final categories = await ref.watch(flattenedCategoryProvider.future);
  return CollectionUtils.safeLookup(categories, (category) => category.id == categoryId);
});

final categoryByNameProvider = FutureProvider.family<Category?, String>((ref, categoryName) async {
  final categories = await ref.watch(flattenedCategoryProvider.future);
  return CollectionUtils.safeLookup(categories, (category) => category.name == categoryName);
});

class CategoryNotifier extends Notifier<Category?> {
  @override
  Category? build() => null;

  void selectCategory(Category? category) {
    state = category;
  }
}

final selectedCategoryProvider = NotifierProvider<CategoryNotifier, Category?>(CategoryNotifier.new);

// map category base on category id lookup O(1)
final categoryMapProvider = FutureProvider<Map<String, Category>>((ref) async {
  final categories = await ref.watch(flattenedCategoryProvider.future);
  return {for (var category in categories) category.id: category};
});
