import 'package:revtrack_mobile/services/api_service.dart';

class NotificationRepository {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getConfig() async {
    return await _apiService.getNotificationConfig();
  }

  Future<Map<String, dynamic>> updateConfig({
    bool? dailyReminder,
    String? reminderHour,
    double? monthlyGoal,
    bool? alertOnGoal,
    bool? alertOnDrop,
    bool? weeklyReport,
  }) async {
    return await _apiService.updateNotificationConfig(
      dailyReminder: dailyReminder,
      reminderHour: reminderHour,
      monthlyGoal: monthlyGoal,
      alertOnGoal: alertOnGoal,
      alertOnDrop: alertOnDrop,
      weeklyReport: weeklyReport,
    );
  }
}