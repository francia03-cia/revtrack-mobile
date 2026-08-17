import 'package:revtrack_mobile/data/models/user.dart';
import 'package:revtrack_mobile/services/api_service.dart';
import 'package:revtrack_mobile/services/http_client.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();

  Future<UserModel> login(String email, String password) async {
    final response = await _apiService.login(
      email: email,
      password: password,
    );
    
    // Sauvegarder le token
    final token = response['token'];
    if (token != null) {
      await HttpClient.setToken(token as String);
    }
    
    // Récupérer l'utilisateur
    final userData = response['user'] as Map<String, dynamic>;
    return UserModel.fromJson(userData);
  }

  Future<UserModel> register(String name, String email, String password) async {
    final response = await _apiService.register(
      name: name,
      email: email,
      password: password,
    );
    
    final token = response['token'];
    if (token != null) {
      await HttpClient.setToken(token as String);
    }
    
    final userData = response['user'] as Map<String, dynamic>;
    return UserModel.fromJson(userData);
  }

  Future<void> logout() async {
    await _apiService.logout();
  }

  Future<UserModel> getCurrentUser() async {
    return await _apiService.getCurrentUser();
  }

  Future<bool> isAuthenticated() async {
    final token = await HttpClient.getToken();
    return token != null && token.isNotEmpty;
  }
}