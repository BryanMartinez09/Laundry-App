class User {
  final String id;
  final String name;
  final String email;
  final String? initials;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.initials,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      initials: json['initials'],
      role: json['role']['name'] ?? 'EMPLOYEE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'initials': initials,
      'role': role,
    };
  }
}

class AuthResponse {
  final String accessToken;
  final User? user;

  AuthResponse({required this.accessToken, this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}
