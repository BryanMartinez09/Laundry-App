import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api/api_client.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  final ApiClient _apiClient = ApiClient();

  Future<void> fetchProfile() async {
    try {
      final response = await _apiClient.dio.get('/auth/profile');
      if (response.statusCode == 200) {
        _user = User.fromJson(response.data);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error al obtener perfil: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final authResponse = AuthResponse.fromJson(response.data);
        _token = authResponse.accessToken;
        _apiClient.setAuthToken(_token!);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', _token!);

        await fetchProfile(); // Cargar datos del usuario
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error en Login: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    _apiClient.clearAuthToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('jwt_token')) return;
    
    _token = prefs.getString('jwt_token');
    _apiClient.setAuthToken(_token!);
    await fetchProfile(); // Recuperar datos del usuario persistente
    notifyListeners();
  }
}
