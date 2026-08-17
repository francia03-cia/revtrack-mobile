import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:revtrack_mobile/services/http_client.dart';
import 'package:revtrack_mobile/data/models/user.dart';
import 'package:revtrack_mobile/data/models/transaction.dart';
import 'package:revtrack_mobile/data/models/category.dart';
import 'package:revtrack_mobile/data/models/startup.dart';

class ApiService {
  final Dio _dio = HttpClient.instance;

  // ============ AUTHENTIFICATION ============
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map) {
        final data = e.response!.data as Map;
        throw Exception(data['message'] ?? 'Erreur de connexion');
      }
      throw Exception('Erreur de connexion au serveur');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/logout');
      await HttpClient.clearToken();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dio.get('/user');
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ============ STARTUPS ============
  Future<List<StartupModel>> getStartups() async {
    try {
      final response = await _dio.get('/startups');
      
      print('🏢 API Startups Response: ${response.data}');
      
      // La réponse a une structure: { "data": [ ... ] }
      if (response.data is Map && response.data.containsKey('data')) {
        final dataList = response.data['data'] as List;
        return dataList
            .map((json) => StartupModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response.data is List) {
        return (response.data as List)
            .map((json) => StartupModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } catch (e) {
      print('❌ Startups Error: $e');
      throw _handleError(e);
    }
  }

  Future<StartupModel> getStartup(int id) async {
    try {
      final response = await _dio.get('/startups/$id');
      
      print('🏢 API Startup Detail Response: ${response.data}');
      
      if (response.data is Map && response.data.containsKey('data')) {
        return StartupModel.fromJson(response.data['data'] as Map<String, dynamic>);
      } else if (response.data is Map) {
        return StartupModel.fromJson(response.data as Map<String, dynamic>);
      }
      
      throw Exception('Format de réponse invalide');
    } catch (e) {
      print('❌ Startup Detail Error: $e');
      throw _handleError(e);
    }
  }

  Future<StartupModel> createStartup(String name, String currency) async {
    try {
      final response = await _dio.post(
        '/startups',
        data: {'name': name, 'currency': currency},
      );
      
      if (response.data is Map && response.data.containsKey('data')) {
        return StartupModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return StartupModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> switchStartup(int startupId) async {
    try {
      await _dio.post('/startups/$startupId/switch');
    } catch (e) {
      throw _handleError(e);
    }
  }

    // ============ CATÉGORIES ============
  Future<List<CategoryModel>> getCategories({int? startupId}) async {
    try {
      final queryParams = startupId != null ? {'startup_id': startupId.toString()} : null;
      final response = await _dio.get(
        '/categories',
        queryParameters: queryParams,
      );
      
      print('📂 API Categories Response: ${response.data}');
      
      // La réponse est directement une liste de catégories (ressource)
      if (response.data is List) {
        return (response.data as List)
            .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      // Alternative: la réponse est dans une clé 'data'
      if (response.data is Map && response.data.containsKey('data')) {
        final dataList = response.data['data'] as List;
        return dataList
            .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } catch (e) {
      print('❌ Categories API Error: $e');
      throw _handleError(e);
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
      final response = await _dio.post(
        '/categories',
        data: {
          'name': name,
          'color': color,
          'icon': icon,
          'startup_id': startupId,
          'parent_id': parentId,
        },
      );
      
      print('✅ Category Created: ${response.data}');
      
      // La réponse peut être directe ou dans 'category'
      if (response.data is Map && response.data.containsKey('category')) {
        return CategoryModel.fromJson(response.data['category'] as Map<String, dynamic>);
      }
      return CategoryModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      print('❌ Create Category Error: $e');
      throw _handleError(e);
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
      final response = await _dio.put(
        '/categories/$id',
        data: {
          'name': name,
          'color': color,
          'icon': icon,
          'startup_id': startupId,
          'parent_id': parentId,
        },
      );
      
      print('✅ Category Updated: ${response.data}');
      
      if (response.data is Map && response.data.containsKey('category')) {
        return CategoryModel.fromJson(response.data['category'] as Map<String, dynamic>);
      }
      return CategoryModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      print('❌ Update Category Error: $e');
      throw _handleError(e);
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _dio.delete('/categories/$id');
      print('✅ Category Deleted: $id');
    } catch (e) {
      print('❌ Delete Category Error: $e');
      throw _handleError(e);
    }
  }

  // ============ PROJETS ============
  Future<Map<String, dynamic>> getProjects({
    int? startupId,
    String? progressStatus,
    String? budgetStatus,
    int? categoryId,
    String? search,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final queryParams = {
        if (startupId != null) 'startup_id': startupId.toString(),
        if (progressStatus != null) 'progress_status': progressStatus,
        if (budgetStatus != null) 'budget_status': budgetStatus,
        if (categoryId != null) 'category_id': categoryId.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      final response = await _dio.get('/projects', queryParameters: queryParams);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createProject({
    required String name,
    required DateTime startDate,
    DateTime? endDate,
    required double budget,
    required int categoryId,
    required int startupId,
    String? description,
  }) async {
    try {
      final response = await _dio.post('/projects', data: {
        'name': name,
        'start_date': startDate.toIso8601String().split('T')[0],
        'end_date': endDate?.toIso8601String().split('T')[0],
        'budget': budget,
        'category_id': categoryId,
        'startup_id': startupId,
        'description': description,
      });
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateProject({
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
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (startDate != null) data['start_date'] = startDate.toIso8601String().split('T')[0];
      if (endDate != null) data['end_date'] = endDate.toIso8601String().split('T')[0];
      if (budget != null) data['budget'] = budget;
      if (categoryId != null) data['category_id'] = categoryId;
      if (description != null) data['description'] = description;
      if (progressStatus != null) data['progress_status'] = progressStatus;

      final response = await _dio.put('/projects/$id', data: data);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteProject(int id) async {
    try {
      await _dio.delete('/projects/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getProjectStats(int startupId) async {
    try {
      final response = await _dio.get('/projects/stats', queryParameters: {
        'startup_id': startupId.toString(),
      });
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ============ TRANSACTIONS ============
  Future<Map<String, dynamic>> getTransactionsPaginated({
    int? startupId,
    String? startDate,
    String? endDate,
    int? categoryId,
    String? search,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final queryParams = {
        if (startupId != null) 'startup_id': startupId.toString(),
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
        if (categoryId != null) 'category_id': categoryId.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      final response = await _dio.get(
        '/transactions',
        queryParameters: queryParams,
      );
      
      print('📋 Transactions Response: ${response.data}');
      
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('❌ Transactions Error: $e');
      throw _handleError(e);
    }
  }

  Future<List<TransactionModel>> getTransactions({
    int? startupId,
    String? startDate,
    String? endDate,
    int? categoryId,
    String? search,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final result = await getTransactionsPaginated(
        startupId: startupId,
        startDate: startDate,
        endDate: endDate,
        categoryId: categoryId,
        search: search,
        page: page,
        perPage: perPage,
      );
      
      // 🔥 La liste est dans 'data'
      final dataList = result['data'] as List? ?? [];
      
      print('📋 Transactions trouvées: ${dataList.length}');
      
      return dataList
          .map((json) => TransactionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Transactions Error: $e');
      throw _handleError(e);
    }
  }

  Future<TransactionModel> createTransaction({
    required double amount,
    required DateTime date,
    required String source,
    String? description,
    required int categoryId,
    required int startupId,
    List<String>? tags,
    String? receipt,
    int? projectId,
  }) async {
    try {
      final response = await _dio.post(
        '/transactions',
        data: {
          'amount': amount,
          'date': date.toIso8601String().split('T')[0],
          'source': source,
          'description': description,
          'category_id': categoryId,
          'startup_id': startupId,
          'tags': tags,
          'receipt': receipt,
          'project_id': projectId,
        },
      );
      return TransactionModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<TransactionModel> updateTransaction({
    required int id,
    double? amount,
    DateTime? date,
    String? source,
    String? description,
    int? categoryId,
    List<String>? tags,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (amount != null) data['amount'] = amount;
      if (date != null) data['date'] = date.toIso8601String().split('T')[0];
      if (source != null) data['source'] = source;
      if (description != null) data['description'] = description;
      if (categoryId != null) data['category_id'] = categoryId;
      if (tags != null) data['tags'] = tags;

      final response = await _dio.put(
        '/transactions/$id',
        data: data,
      );
      return TransactionModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await _dio.delete('/transactions/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> bulkDeleteTransactions(List<int> ids) async {
    try {
      await _dio.post(
        '/transactions/bulk-delete',
        data: {'ids': ids},
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ============ DASHBOARD ============
  Future<Map<String, dynamic>> getKpis({int? startupId}) async {
    try {
      final queryParams = startupId != null ? {'startup_id': startupId.toString()} : null;
      final response = await _dio.get(
        '/dashboard/kpis',
        queryParameters: queryParams,
      );
      
      print('📊 KPIS API Response: ${response.data}');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('❌ KPIS API Error: $e');
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getChartData({
    int? startupId,
    String period = 'month',
  }) async {
    try {
      final queryParams = {
        if (startupId != null) 'startup_id': startupId.toString(),
        'period': period,
      };
      final response = await _dio.get(
        '/dashboard/charts',
        queryParameters: queryParams,
      );
      
      print('📊 Chart API Response: ${response.data}');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('❌ Chart API Error: $e');
      throw _handleError(e);
    }
  }

  // ============ EXPORTS ============
  Future<Response> exportPdf({
    required int startupId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      return await _dio.get(
        '/export/pdf',
        queryParameters: {
          'startup_id': startupId.toString(),
          'start_date': startDate,
          'end_date': endDate,
        },
        options: Options(responseType: ResponseType.bytes),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> exportExcel({
    required int startupId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      return await _dio.get(
        '/export/excel',
        queryParameters: {
          'startup_id': startupId.toString(),
          'start_date': startDate,
          'end_date': endDate,
        },
        options: Options(responseType: ResponseType.bytes),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ============ NOTIFICATIONS ============
  Future<Map<String, dynamic>> getNotificationConfig() async {
    try {
      final response = await _dio.get('/notifications/config');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateNotificationConfig({
    bool? dailyReminder,
    String? reminderHour,
    double? monthlyGoal,
    bool? alertOnGoal,
    bool? alertOnDrop,
    bool? weeklyReport,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (dailyReminder != null) data['daily_reminder'] = dailyReminder;
      if (reminderHour != null) data['reminder_hour'] = reminderHour;
      if (monthlyGoal != null) data['monthly_goal'] = monthlyGoal;
      if (alertOnGoal != null) data['alert_on_goal'] = alertOnGoal;
      if (alertOnDrop != null) data['alert_on_drop'] = alertOnDrop;
      if (weeklyReport != null) data['weekly_report'] = weeklyReport;

      final response = await _dio.put(
        '/notifications/config',
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ============ GESTION DES ERREURS ============
  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final data = error.response!.data;
        if (data is Map && data.containsKey('message')) {
          return data['message'];
        }
        if (data is Map && data.containsKey('errors')) {
          return data['errors'].toString();
        }
        return 'Erreur: ${error.response!.statusCode}';
      }
      return error.message ?? 'Erreur de connexion';
    }
    return error.toString();
  }
}