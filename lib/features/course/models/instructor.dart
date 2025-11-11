import 'package:flutter/foundation.dart';

@immutable
class Instructor {
  final String id;
  final String name;
  final String? email;
  final String? bio;
  final String? avatarUrl;
  final String? specialization;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Instructor({
    required this.id,
    required this.name,
    this.email,
    this.bio,
    this.avatarUrl,
    this.specialization,
    this.createdAt,
    this.updatedAt,
  });

  Instructor copyWith({
    String? id,
    String? name,
    String? email,
    String? bio,
    String? avatarUrl,
    String? specialization,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Instructor(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      specialization: specialization ?? this.specialization,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Instructor.fromMap(Map<String, dynamic> map) {
    return Instructor(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String?,
      bio: map['bio'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      specialization: map['specialization'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'bio': bio,
      'avatar_url': avatarUrl,
      'specialization': specialization,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class InstructorInput {
  final String name;
  final String? email;
  final String? bio;
  final String? avatarUrl;
  final String? specialization;

  const InstructorInput({
    required this.name,
    this.email,
    this.bio,
    this.avatarUrl,
    this.specialization,
  });

  Map<String, dynamic> toInsert() => {
        'name': name,
        'email': email,
        'bio': bio,
        'avatar_url': avatarUrl,
        'specialization': specialization,
      }..removeWhere((key, value) => value == null);

  Map<String, dynamic> toUpdate() => {
        'name': name,
        'email': email,
        'bio': bio,
        'avatar_url': avatarUrl,
        'specialization': specialization,
        'updated_at': DateTime.now().toIso8601String(),
      }..removeWhere((key, value) => value == null);
}
