import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../models/catalog_item_model.dart';

class CatalogProvider with ChangeNotifier {
  List<CatalogItemModel> _items = [];
  bool _isLoading = false;

  List<CatalogItemModel> get items => _items;
  bool get isLoading => _isLoading;

  // Organizar items por categoría
  List<CatalogItemModel> getItemsByCategory(String category) {
    return _items.where((item) => item.category == category).toList();
  }

  Future<void> fetchCatalog() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient().dio.get('/forms/catalog');
      final List<dynamic> data = response.data;
      _items = data.map((json) => CatalogItemModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching catalog: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
