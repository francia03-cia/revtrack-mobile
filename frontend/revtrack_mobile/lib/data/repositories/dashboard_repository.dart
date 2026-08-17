import 'package:revtrack_mobile/data/models/dashboard.dart';
import 'package:revtrack_mobile/services/api_service.dart';

class DashboardRepository {
  final ApiService _apiService = ApiService();

  Future<DashboardKpis> getKpis({int? startupId}) async {
    try {
      final response = await _apiService.getKpis(startupId: startupId);
      print('📊 KPIS Response: $response');
      return DashboardKpis.fromJson(response);
    } catch (e) {
      print('❌ KPIS Error: $e');
      rethrow;
    }
  }

  Future<DashboardChartData> getChartData({
    int? startupId,
    String period = 'month',
  }) async {
    try {
      final response = await _apiService.getChartData(
        startupId: startupId,
        period: period,
      );
      print('📊 Chart Response: $response');
      return DashboardChartData.fromJson(response);
    } catch (e) {
      print('❌ Chart Error: $e');
      rethrow;
    }
  }
}