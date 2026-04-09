import 'package:flutter/material.dart';
import '../models/company_model.dart';
import '../core/api/api_client.dart';

class CompanyProvider extends ChangeNotifier {
  List<Company> _companies = [];
  bool _isLoading = false;

  List<Company> get companies => _companies;
  bool get isLoading => _isLoading;

  final ApiClient _apiClient = ApiClient();

  Future<void> fetchCompanies() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get('/companies');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _companies = data.map((json) => Company.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching companies: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
