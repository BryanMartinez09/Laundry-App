import 'package:flutter/material.dart';
import '../core/api/api_client.dart';

class RolesProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  
  List<dynamic> _roles = [];
  List<dynamic> _availablePermissions = [];
  bool _isLoading = false;

  List<dynamic> get roles => _roles;
  List<dynamic> get availablePermissions => _availablePermissions;
  bool get isLoading => _isLoading;

  Future<void> fetchRoles() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.get('/roles');
      if (response.statusCode == 200) {
        _roles = response.data;
      }
    } catch (e) {
      debugPrint('Error fetching roles: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAvailablePermissions() async {
    try {
      final response = await _apiClient.dio.get('/roles/available-permissions');
      if (response.statusCode == 200) {
        _availablePermissions = response.data['view_actions'];
      }
    } catch (e) {
      debugPrint('Error fetching available permissions: $e');
    }
    notifyListeners();
  }

  Future<bool> updatePermissions(String roleId, List<dynamic> permissions) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.dio.patch('/roles/$roleId/permissions', data: permissions);
      if (response.statusCode == 200) {
        // Update local state
        final idx = _roles.indexWhere((r) => r['id'] == roleId);
        if (idx != -1) {
          _roles[idx]['permissions'] = permissions;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error updating permissions: $e');
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }
}
