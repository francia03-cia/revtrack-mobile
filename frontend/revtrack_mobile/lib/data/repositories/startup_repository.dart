import 'package:revtrack_mobile/data/models/startup.dart';
import 'package:revtrack_mobile/services/api_service.dart';

class StartupRepository {
  final ApiService _apiService = ApiService();

  Future<List<StartupModel>> getStartups() async {
    try {
      final result = await _apiService.getStartups();
      print('🏢 Repository Startups: ${result.length} found');
      return result;
    } catch (e) {
      print('❌ Repository Startups Error: $e');
      rethrow;
    }
  }

  Future<StartupModel> getStartup(int id) async {
    try {
      return await _apiService.getStartup(id);
    } catch (e) {
      print('❌ Repository Startup Detail Error: $e');
      rethrow;
    }
  }

  Future<StartupModel> createStartup(String name, String currency) async {
    try {
      return await _apiService.createStartup(name, currency);
    } catch (e) {
      print('❌ Repository Create Startup Error: $e');
      rethrow;
    }
  }

  Future<void> switchStartup(int startupId) async {
    try {
      await _apiService.switchStartup(startupId);
    } catch (e) {
      print('❌ Repository Switch Startup Error: $e');
      rethrow;
    }
  }
}