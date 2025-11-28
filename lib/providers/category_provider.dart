import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mosa/models/category.dart';
import 'package:mosa/services/category_service.dart';

final categoriesProvider = FutureProvider<List<Category>>((ref) {
  return CategoryService.loadCategories();
});

final categoryByTypeProvider = FutureProvider.family<List<Category>, String>((ref, categoryType) async {
  final categories = await ref.watch(categoriesProvider.future);
  return categories.where((element) => element.type == categoryType).toList();
});

final flattenedCategoryProvider = FutureProvider<List<Category>>((ref) async {
  final categories = await ref.watch(categoriesProvider.future);
  List<Category> flattenedCategory = [];
  for (var category in categories) {
    if (!flattenedCategory.contains(category)) {
      flattenedCategory.add(category);
    }
    if (category.children != null && category.children!.isNotEmpty) {
      flattenedCategory.addAll(category.children!);
    }
  }
  return flattenedCategory;
});

final categoryByIdProvider = FutureProvider.family<Category?, String>((ref, cateogryId) async {
  final categories = await ref.watch(flattenedCategoryProvider.future);
  try {
    return categories.firstWhere((element) {
      return element.id == cateogryId;
    });
  } catch (e) {
    return null;
  }
});

class CategoryNotifier extends Notifier<Category?> {
  @override
  Category? build() => null;

  void selectCategory(Category? category) {
    state = category;
  }
}

final selectedCategoryProvider = NotifierProvider<CategoryNotifier, Category?>(CategoryNotifier.new);
