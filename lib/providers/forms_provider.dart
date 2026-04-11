import 'package:flutter/material.dart';
import '../models/laundry_form_model.dart';
import '../core/api/api_client.dart';

class FormsProvider extends ChangeNotifier {
  List<LaundryForm> _recentForms = [];
  bool _isLoading = false;
  
  int _todayCount = 0;
  int _pendingCount = 0;

  List<LaundryForm> get recentForms => _recentForms;
  bool get isLoading => _isLoading;
  int get todayCount => _todayCount;
  int get pendingCount => _pendingCount;

  final ApiClient _apiClient = ApiClient();

  Future<void> fetchStats() async {
    try {
      final response = await _apiClient.dio.get('/forms/stats');
      if (response.statusCode == 200) {
        _todayCount = response.data['today'];
        _pendingCount = response.data['pending'];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching stats: $e');
    }
  }

  Future<void> fetchRecentForms({Map<String, dynamic>? filters}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get('/forms', queryParameters: filters);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _recentForms = data.map((json) => LaundryForm.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching forms: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> submitForm(LaundryForm form) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.dio.post('/forms', data: form.toJson());
      if (response.statusCode == 201) {
        await fetchStats(); // Refrescar contadores
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error submitting form: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> approveForm(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.dio.patch('/forms/$id/approve');
      if (response.statusCode == 200) {
        await fetchStats();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error approving form: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}
