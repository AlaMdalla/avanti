import 'package:flutter/foundation.dart';
import 'instructor.dart';

@immutable
class Course {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? pdfUrl;
  final String instructorId;
  final Instructor? instructor;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Course({
    required this.id,
    required this.title,
    required this.instructorId,
    this.description,
    this.imageUrl,
    this.pdfUrl,
    this.instructor,
    this.createdAt,
    this.updatedAt,
  });

  Course copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? pdfUrl,
    String? instructorId,
    Instructor? instructor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      instructorId: instructorId ?? this.instructorId,
      instructor: instructor ?? this.instructor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      imageUrl: map['image_url'] as String?,
      pdfUrl: map['pdf_url'] as String?,
      instructorId: map['instructor_id'] as String,
      instructor: map['instructors'] != null
          ? Instructor.fromMap(map['instructors'] as Map<String, dynamic>)
          : null,
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
      'image_url': imageUrl,
      'pdf_url': pdfUrl,
      'instructor_id': instructorId,
      'instructor': instructor?.toMap(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class CourseInput {
  final String title;
  final String? description;
  final String? imageUrl;
  final String? pdfUrl;

  const CourseInput({
    required this.title,
    this.description,
    this.imageUrl,
    this.pdfUrl,
  });

  Map<String, dynamic> toInsert(String instructorId) => {
        'title': title,
        'description': description,
        'image_url': imageUrl,
        'pdf_url': pdfUrl,
        'instructor_id': instructorId,
      };

  Map<String, dynamic> toUpdate() => {
        'title': title,
        'description': description,
        'image_url': imageUrl,
        'pdf_url': pdfUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }..removeWhere((key, value) => value == null);
}
