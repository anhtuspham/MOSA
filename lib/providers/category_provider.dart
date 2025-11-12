import 'package:flutter_riverpod/legacy.dart';
import 'package:mosa/models/category.dart';

class CategoryNotifier extends StateNotifier<Category?> {
  CategoryNotifier() : super(null);

  void selectCategory(Category category) {
    state = category;
  }
}

final categoryNotifier = StateNotifierProvider<CategoryNotifier, Category?>((ref) {
  return CategoryNotifier();
});
