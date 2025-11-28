import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mosa/models/category.dart';
import 'package:mosa/services/category_service.dart';
import 'package:mosa/utils/collection_utils.dart';
import 'package:mosa/utils/tree_utils.dart';

final categoriesProvider = FutureProvider<List<Category>>((ref) {
  return CategoryService.loadCategories();
});

final categoryByTypeProvider = FutureProvider.family<List<Category>, String>((ref, categoryType) async {
  final categories = await ref.watch(categoriesProvider.future);
  return categories.where((element) => element.type == categoryType).toList();
});

final flattenedCategoryProvider = FutureProvider<List<Category>>((ref) async {
  final categories = await ref.watch(categoriesProvider.future);
  return TreeUtils.flatten(categories, (category) => category.children);
});

final categoryByIdProvider = FutureProvider.family<Category?, String>((ref, cateogryId) async {
  final categories = await ref.watch(flattenedCategoryProvider.future);
  return CollectionUtils.safeLookup(categories, (category) => category.id == cateogryId);
});

class CategoryNotifier extends Notifier<Category?> {
  @override
  Category? build() => null;

  void selectCategory(Category? category) {
    state = category;
  }
}

final selectedCategoryProvider = NotifierProvider<CategoryNotifier, Category?>(CategoryNotifier.new);
