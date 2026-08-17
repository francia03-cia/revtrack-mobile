import 'package:revtrack_mobile/data/models/startup.dart';

class UserModel {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final List<StartupModel>? startups;
  final NotificationConfig? notificationConfig;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.startups,
    this.notificationConfig,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
      startups: json['startups'] != null
          ? (json['startups'] as List)
              .map((s) => StartupModel.fromJson(s as Map<String, dynamic>))
              .toList()
          : null,
      notificationConfig: json['notification_config'] != null
          ? NotificationConfig.fromJson(json['notification_config'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
    };
  }
}

class NotificationConfig {
  final int id;
  final bool dailyReminder;
  final String reminderHour;
  final double? monthlyGoal;
  final bool alertOnGoal;
  final bool alertOnDrop;
  final bool weeklyReport;

  NotificationConfig({
    required this.id,
    required this.dailyReminder,
    required this.reminderHour,
    this.monthlyGoal,
    required this.alertOnGoal,
    required this.alertOnDrop,
    required this.weeklyReport,
  });

  factory NotificationConfig.fromJson(Map<String, dynamic> json) {
    return NotificationConfig(
      id: json['id'] ?? 0,
      dailyReminder: json['daily_reminder'] ?? true,
      reminderHour: json['reminder_hour'] ?? '18:00:00',
      monthlyGoal: _parseDoubleNullable(json['monthly_goal']),
      alertOnGoal: json['alert_on_goal'] ?? true,
      alertOnDrop: json['alert_on_drop'] ?? true,
      weeklyReport: json['weekly_report'] ?? true,
    );
  }

  static double? _parseDoubleNullable(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    if (value is num) return value.toDouble();
    return null;
  }
}