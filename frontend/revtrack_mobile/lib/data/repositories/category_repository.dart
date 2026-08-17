import 'package:revtrack_mobile/data/models/category.dart';
import 'package:revtrack_mobile/services/api_service.dart';

class CategoryRepository {
  final ApiService _apiService = ApiService();

  Future<List<CategoryModel>> getCategories({int? startupId}) async {
    try {
      final result = await _apiService.getCategories(startupId: startupId);
      print('📂 Categories Repository: ${result.length} found');
      return result;
    } catch (e) {
      print('❌ Categories Repository Error: $e');
      rethrow;
    }
  }

  Future<CategoryModel> createCategory({
    required String name,
    required String color,
    required String icon,
    required int startupId,
    int? parentId,
  }) async {
    try {
      return await _apiService.createCategory(
        name: name,
        color: color,
        icon: icon,
        startupId: startupId,
        parentId: parentId,
      );
    } catch (e) {
      print('❌ Create Category Error: $e');
      rethrow;
    }
  }

  Future<CategoryModel> updateCategory({
    required int id,
    required String name,
    required String color,
    required String icon,
    required int startupId,
    int? parentId,
  }) async {
    try {
      return await _apiService.updateCategory(
        id: id,
        name: name,
        color: color,
        icon: icon,
        startupId: startupId,
        parentId: parentId,
      );
    } catch (e) {
      print('❌ Update Category Error: $e');
      rethrow;
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _apiService.deleteCategory(id);
    } catch (e) {
      print('❌ Delete Category Error: $e');
      rethrow;
    }
  }
}