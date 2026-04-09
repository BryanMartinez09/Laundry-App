import '../models/laundry_form_model.dart';
import '../models/company_model.dart'; // Just in case, but Catalog is global

class CatalogItemModel {
  final String id;
  final String name;
  final String category;
  final String? size;
  final int displayOrder;

  CatalogItemModel({
    required this.id,
    required this.name,
    required this.category,
    this.size,
    required this.displayOrder,
  });

  factory CatalogItemModel.fromJson(Map<String, dynamic> json) {
    return CatalogItemModel(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      size: json['size'],
      displayOrder: json['displayOrder'] ?? 0,
    );
  }
}
