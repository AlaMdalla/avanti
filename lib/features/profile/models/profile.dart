class Profile {
  final String id;
  final String userId;
  final String? firstName;
  final String? lastName;
  final String? pseudo;
  final String? avatarUrl;
  final String? phone;
  final ProfileRole role;
  final DateTime createdAt;
  final DateTime updatedAt;

  Profile({
    required this.id,
    required this.userId,
    this.firstName,
    this.lastName,
    this.pseudo,
    this.avatarUrl,
    this.phone,
  required this.createdAt,
    required this.updatedAt,
  this.role = ProfileRole.user,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      userId: json['user_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      pseudo: json['pseudo'],
      avatarUrl: json['avatar_url'],
      phone: json['phone'],
      role: ProfileRoleX.fromJson(json['role']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'pseudo': pseudo,
      'avatar_url': avatarUrl,
      'phone': phone,
  'role': role.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Profile copyWith({
    String? id,
    String? userId,
    String? firstName,
    String? lastName,
    String? pseudo,
    String? avatarUrl,
    String? phone,
    ProfileRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      pseudo: pseudo ?? this.pseudo,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get displayName {
    if (firstName != null || lastName != null) {
      return '${firstName ?? ''} ${lastName ?? ''}'.trim();
    }
    return pseudo ?? 'User';
  }
}

enum ProfileRole { admin, user }

extension ProfileRoleX on ProfileRole {
  static ProfileRole fromJson(dynamic v) {
    final s = (v ?? 'user').toString();
    return s == 'admin' ? ProfileRole.admin : ProfileRole.user;
  }
}