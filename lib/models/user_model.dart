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
    // 1. El rol ADMIN maestro siempre tiene acceso total
    if (role.name.toUpperCase() == 'ADMIN') return true;

    // 2. Normalizar entradas
    final String targetView = view.trim().toLowerCase();
    final String targetAction = action.trim().toLowerCase();

    // 3. Usar EXCLUSIVAMENTE la matriz móvil para el App
    final List mobilePerms = role.permissionsMobile;
    
    Map<String, dynamic>? foundModule;
    for (var p in mobilePerms) {
      if (p is Map) {
        final String? viewName = p['view']?.toString().trim().toLowerCase();
        // Coincidencia por nombre interno o sub-label
        if (viewName != null && (viewName == targetView || viewName.contains(targetView))) {
          foundModule = Map<String, dynamic>.from(p);
          break;
        }
      }
    }
    
    if (foundModule == null) return false;

    // 4. Verificar la acción
    final List actions = foundModule['actions'] ?? [];
    return actions.any((a) => a.toString().trim().toLowerCase() == targetAction);
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
