class Company {
  final String id;
  final String name;
  final String? address;
  final String? phone;
  final bool isActive;

  Company({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    this.isActive = true,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'isActive': isActive,
    };
  }
}
