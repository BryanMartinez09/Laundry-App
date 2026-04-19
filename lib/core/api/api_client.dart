import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  // Use localhost for web, 10.0.2.2 for Android emulator, or actual IP for physical devices
  static String get baseUrl {
    if (kIsWeb) return dotenv.env['API_URL_WEB'] ?? 'http://localhost:8080';
    
    // For mobile (Physical or Emulator fallback)
    return dotenv.env['API_URL_MOBILE'] ?? 'http://192.168.1.3:8080';
  }
  
  final Dio dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // Singleton
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  // Método para añadir el token a las cabeceras después del login
  void setAuthToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    dio.options.headers.remove('Authorization');
  }
}
