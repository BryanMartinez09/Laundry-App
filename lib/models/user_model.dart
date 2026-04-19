class User {
  final String id;
  final String name;
  final String email;
  final String? initials;
  final RoleModel role;

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
      role: RoleModel.fromJson(json['role']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'initials': initials,
      'role': role.toJson(),
    };
  }

  bool hasPermission(String view, String action) {
    if (email == 'admin@laundry.com') return true;
    
    // Switch to permissionsMobile for app-specific logic
    final List rolePerms = role.permissionsMobile;
    Map<String, dynamic>? perm;
    for (var p in rolePerms) {
      if (p is Map && p['view'] == view) {
        perm = Map<String, dynamic>.from(p);
        break;
      }
    }
    
    if (perm == null) return false;
    final List actions = perm['actions'] ?? [];
    return actions.contains(action);
  }
}

class RoleModel {
  final String name;
  final List<dynamic> permissions;
  final List<dynamic> permissionsMobile;

  RoleModel({
    required this.name, 
    required this.permissions,
    required this.permissionsMobile,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      name: json['name'] ?? 'EMPLOYEE',
      permissions: json['permissions'] ?? [],
      permissionsMobile: json['permissions_mobile'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'permissions': permissions,
      'permissionsMobile': permissionsMobile,
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
