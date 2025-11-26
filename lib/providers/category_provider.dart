import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mosa/models/category.dart';
import 'package:mosa/services/category_service.dart';

final categoriesProvider = FutureProvider<List<Category>>((ref) {
  return CategoryService.loadCategories();
});

final categoryByTypeProvider = FutureProvider.family<List<Category>, String>((ref, categoryType) async {
  final categories = await ref.watch(categoriesProvider.future);
  return categories.where((element) => element.type == categoryType).toList();
});

class CategoryNotifier extends Notifier<Category?> {
  @override
  Category? build() => null;

  void selectCategory(Category? category) {
    state = category;
  }
}

final selectedCategoryProvider = NotifierProvider<CategoryNotifier, Category?>(CategoryNotifier.new);
