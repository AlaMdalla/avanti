import 'package:flutter/foundation.dart';
import 'course.dart';

@immutable
class Module {
  final String id;
  final String title;
  final String? description;
  final int? order;
  final List<Course> courses;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Module({
    required this.id,
    required this.title,
    this.description,
    this.order,
    this.courses = const [],
    this.createdAt,
    this.updatedAt,
  });

  Module copyWith({
    String? id,
    String? title,
    String? description,
    int? order,
    List<Course>? courses,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Module(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      order: order ?? this.order,
      courses: courses ?? this.courses,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Module.fromMap(Map<String, dynamic> map) {
    // Handle courses - could be a List, Map, or null
    List<Course> courses = [];
    final coursesData = map['courses'];
    
    if (coursesData != null) {
      if (coursesData is List) {
        // It's a list of courses
        courses = (coursesData as List<dynamic>)
            .map((e) => Course.fromMap(e as Map<String, dynamic>))
            .toList();
      } else if (coursesData is Map) {
        // It's a single course object
        courses = [Course.fromMap(coursesData as Map<String, dynamic>)];
      }
    }

    return Module(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      order: map['order'] as int?,
      courses: courses,
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
      'title': title,
      'description': description,
      'order': order,
      'courses': courses.map((course) => course.toMap()).toList(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class ModuleInput {
  final String title;
  final String? description;
  final int? order;

  const ModuleInput({
    required this.title,
    this.description,
    this.order,
  });

  Map<String, dynamic> toInsert() => {
        'title': title,
        'description': description,
        'order': order,
      }..removeWhere((key, value) => value == null);

  Map<String, dynamic> toUpdate() => {
        'title': title,
        'description': description,
        'order': order,
        'updated_at': DateTime.now().toIso8601String(),
      }..removeWhere((key, value) => value == null);
}
