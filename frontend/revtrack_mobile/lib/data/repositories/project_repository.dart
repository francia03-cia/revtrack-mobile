import 'package:revtrack_mobile/data/models/project.dart';
import 'package:revtrack_mobile/services/api_service.dart';

class ProjectRepository {
  final ApiService _apiService = ApiService();

  Future<List<ProjectModel>> getProjects({
    int? startupId,
    String? progressStatus,
    String? budgetStatus,
    int? categoryId,
    String? search,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final response = await _apiService.getProjects(
        startupId: startupId,
        progressStatus: progressStatus,
        budgetStatus: budgetStatus,
        categoryId: categoryId,
        search: search,
        page: page,
        perPage: perPage,
      );
      
      final dataList = response['data'] as List? ?? [];
      return dataList
          .map((json) => ProjectModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Projects Error: $e');
      rethrow;
    }
  }

  Future<ProjectModel> createProject({
    required String name,
    required DateTime startDate,
    DateTime? endDate,
    required double budget,
    required int categoryId,
    required int startupId,
    String? description,
  }) async {
    try {
      final response = await _apiService.createProject(
        name: name,
        startDate: startDate,
        endDate: endDate,
        budget: budget,
        categoryId: categoryId,
        startupId: startupId,
        description: description,
      );
      return ProjectModel.fromJson(response['data']);
    } catch (e) {
      print('❌ Create Project Error: $e');
      rethrow;
    }
  }

  Future<ProjectModel> updateProject({
    required int id,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    double? budget,
    int? categoryId,
    String? description,
    String? progressStatus,
  }) async {
    try {
      final response = await _apiService.updateProject(
        id: id,
        name: name,
        startDate: startDate,
        endDate: endDate,
        budget: budget,
        categoryId: categoryId,
        description: description,
        progressStatus: progressStatus,
      );
      return ProjectModel.fromJson(response['data']);
    } catch (e) {
      print('❌ Update Project Error: $e');
      rethrow;
    }
  }

  Future<void> deleteProject(int id) async {
    try {
      await _apiService.deleteProject(id);
    } catch (e) {
      print('❌ Delete Project Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getStats(int startupId) async {
    try {
      return await _apiService.getProjectStats(startupId);
    } catch (e) {
      print('❌ Project Stats Error: $e');
      rethrow;
    }
  }
}