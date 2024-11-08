import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryNotifier extends StateNotifier<List<Category>> {
  CategoryNotifier() : super([]) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesData = prefs.getStringList('categories') ?? [];
    state = categoriesData.map((categoryString) {
      final Map<String, dynamic> categoryMap = json.decode(categoryString);
      return Category.fromMap(categoryMap);
    }).toList();
  }

  Future<void> saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesData = state.map((category) => json.encode(category.toMap())).toList();
    await prefs.setStringList('categories', categoriesData);
  }

  void addCategory(Category category) {
    state = [...state, category];
    saveCategories();
  }

  void removeCategory(String categoryId) {
    state = state.where((category) => category.id != categoryId).toList();
    saveCategories();
  }

  Future<void> updateCategory(String categoryId, {String? name, File? coverImage}) async {
    state = state.map((category) {
      if (category.id == categoryId) {
        return category.copyWith(
          name: name ?? category.name,
          coverImage: coverImage ?? category.coverImage,
        );
      }
      return category;
    }).toList();

    await saveCategories();
  }
}

final categoryProvider = StateNotifierProvider<CategoryNotifier, List<Category>>((ref) {
  return CategoryNotifier();
});
