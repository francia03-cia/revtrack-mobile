class ApiConfig {
  // Base URL - À changer selon l'environnement
  static const String baseUrl = 'http://localhost:8000/api';
  // Pour les appareils physiques : 'http://192.168.1.XX:8000/api/v1'
  // Pour Android Emulator : 'http://10.0.2.2:8000/api/v1'
  // Pour iOS Simulator : 'http://localhost:8000/api/v1'

  static const String register = '$baseUrl/register';
  static const String login = '$baseUrl/login';
  static const String logout = '$baseUrl/logout';
  static const String user = '$baseUrl/user';
  static const String transactions = '$baseUrl/transactions';
  static const String startups = '$baseUrl/startups';
  static const String categories = '$baseUrl/categories';
  static const String dashboardKpis = '$baseUrl/dashboard/kpis';
  static const String dashboardCharts = '$baseUrl/dashboard/charts';
  static const String exportPdf = '$baseUrl/export/pdf';
  static const String exportExcel = '$baseUrl/export/excel';
  static const String notificationConfig = '$baseUrl/notifications/config';
}