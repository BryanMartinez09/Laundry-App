import 'company_model.dart';

enum FormStatus { DRAFT, PENDING_APPROVAL, APPROVED }

class LaundryForm {
  final String? id;
  final String companyId;
  final Company? company; // Para cuando viene de la API con relación
  final DateTime date;
  final int pocketCount;
  final int plasticBagsSmall;
  final int plasticBagsLarge;
  final String? notes;
  final int totalTaiesMain;
  final int totalDrapsMain;
  final List<FormSectionModel> sections;
  final FormStatus status;

  LaundryForm({
    this.id,
    required this.companyId,
    this.company,
    required this.date,
    this.pocketCount = 0,
    this.plasticBagsSmall = 0,
    this.plasticBagsLarge = 0,
    this.notes,
    this.totalTaiesMain = 0,
    this.totalDrapsMain = 0,
    required this.sections,
    this.status = FormStatus.DRAFT,
  });

  factory LaundryForm.fromJson(Map<String, dynamic> json) {
    return LaundryForm(
      id: json['id'],
      companyId: json['companyId'] ?? (json['company']?['id'] ?? ''),
      company: json['company'] != null ? Company.fromJson(json['company']) : null,
      date: DateTime.parse(json['date'] ?? json['created_at']),
      pocketCount: json['pocketCount'] ?? 0,
      plasticBagsSmall: json['plasticBagsSmall'] ?? 0,
      plasticBagsLarge: json['plasticBagsLarge'] ?? 0,
      notes: json['notes'],
      totalTaiesMain: json['totalTaiesMain'] ?? 0,
      totalDrapsMain: json['totalDrapsMain'] ?? 0,
      status: _parseStatus(json['status']),
      sections: (json['sections'] as List? ?? [])
          .map((s) => FormSectionModel.fromJson(s))
          .toList(),
    );
  }

  static FormStatus _parseStatus(String? status) {
    switch (status) {
      case 'PENDING_APPROVAL':
        return FormStatus.PENDING_APPROVAL;
      case 'APPROVED':
        return FormStatus.APPROVED;
      default:
        return FormStatus.DRAFT;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'companyId': companyId,
      'date': date.toIso8601String().split('T')[0],
      'pocketCount': pocketCount,
      'plasticBagsSmall': plasticBagsSmall,
      'plasticBagsLarge': plasticBagsLarge,
      'notes': notes,
      'totalTaiesMain': totalTaiesMain,
      'totalDrapsMain': totalDrapsMain,
      'sections': sections.map((s) => s.toJson()).toList(),
    };
  }
}

class FormSectionModel {
  final String sectionName;
  final String filledByInitials;
  final List<FormItemModel> items;

  FormSectionModel({
    required this.sectionName,
    required this.filledByInitials,
    required this.items,
  });

  factory FormSectionModel.fromJson(Map<String, dynamic> json) {
    return FormSectionModel(
      sectionName: json['sectionName'] ?? '',
      filledByInitials: json['filledByInitials'] ?? '??',
      items: (json['items'] as List? ?? [])
          .map((i) => FormItemModel.fromJson(i))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sectionName': sectionName,
      'filledByInitials': filledByInitials,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}

class FormItemModel {
  final String category;
  final String? size;
  final bool isColored;
  final int quantity;

  FormItemModel({
    required this.category,
    this.size,
    required this.isColored,
    required this.quantity,
  });

  factory FormItemModel.fromJson(Map<String, dynamic> json) {
    return FormItemModel(
      category: json['category'] ?? '',
      size: json['size'],
      isColored: json['isColored'] ?? false,
      quantity: json['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'size': size,
      'isColored': isColored,
      'quantity': quantity,
    };
  }
}
