import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:mosa/models/category.dart';

class CategoryService {
  static Future<List<Category>> loadCategories() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/categories.json');
      log('Loaded categories: ${jsonDecode(jsonString).runtimeType}');

      final List<dynamic> jsonList = jsonDecode(jsonString);

      return jsonList.map((e) => Category.fromJson(e)).toList();
    } catch (e) {
      log('Error in loadCategories: ${e.toString()}');
      return [];
    }
  }
}
