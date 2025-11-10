import 'package:flutter/material.dart';

enum ReclamationCategory {
  courseIssue('course_issue', 'Course Issue', Icons.library_books),
  contentIssue('content_issue', 'Content Issue', Icons.description),
  technical('technical', 'Technical Issue', Icons.bug_report),
  other('other', 'Other', Icons.more_horiz);

  final String value;
  final String label;
  final IconData icon;

  const ReclamationCategory(this.value, this.label, this.icon);

  static ReclamationCategory fromString(String value) {
    return ReclamationCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ReclamationCategory.other,
    );
  }
}

enum ReclamationStatus {
  open('open', 'Open', Color(0xFF3B82F6)), // Blue
  inProgress('in_progress', 'In Progress', Color(0xFFF59E0B)), // Amber
  resolved('resolved', 'Resolved', Color(0xFF10B981)), // Green
  closed('closed', 'Closed', Color(0xFF6B7280)); // Gray

  final String value;
  final String label;
  final Color color;

  const ReclamationStatus(this.value, this.label, this.color);

  static ReclamationStatus fromString(String value) {
    return ReclamationStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ReclamationStatus.open,
    );
  }
}

enum ReclamationPriority {
  low('low', 'Low', Color(0xFF10B981)), // Green
  medium('medium', 'Medium', Color(0xFFF59E0B)), // Amber
  high('high', 'High', Color(0xFFEF4444)), // Red
  urgent('urgent', 'Urgent', Color(0xFF7C3AED)); // Purple

  final String value;
  final String label;
  final Color color;

  const ReclamationPriority(this.value, this.label, this.color);

  static ReclamationPriority fromString(String value) {
    return ReclamationPriority.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ReclamationPriority.medium,
    );
  }
}

class Reclamation {
  final String id;
  final String userId;
  final String? courseId;
  final String? moduleId;
  final String title;
  final String description;
  final ReclamationCategory category;
  final ReclamationStatus status;
  final ReclamationPriority priority;
  final int? ratingBefore;
  final int? ratingAfter;
  final String? attachmentUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;

  Reclamation({
    required this.id,
    required this.userId,
    this.courseId,
    this.moduleId,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.priority,
    this.ratingBefore,
    this.ratingAfter,
    this.attachmentUrl,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
  });

  factory Reclamation.fromMap(Map<String, dynamic> map) {
    return Reclamation(
      id: map['id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      courseId: map['course_id'] as String?,
      moduleId: map['module_id'] as String?,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: ReclamationCategory.fromString(map['category'] as String? ?? 'other'),
      status: ReclamationStatus.fromString(map['status'] as String? ?? 'open'),
      priority: ReclamationPriority.fromString(map['priority'] as String? ?? 'medium'),
      ratingBefore: map['rating_before'] as int?,
      ratingAfter: map['rating_after'] as int?,
      attachmentUrl: map['attachment_url'] as String?,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'].toString()) : DateTime.now(),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'].toString()) : DateTime.now(),
      resolvedAt: map['resolved_at'] != null ? DateTime.parse(map['resolved_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'module_id': moduleId,
      'title': title,
      'description': description,
      'category': category.value,
      'status': status.value,
      'priority': priority.value,
      'rating_before': ratingBefore,
      'rating_after': ratingAfter,
      'attachment_url': attachmentUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
    };
  }

  Reclamation copyWith({
    String? id,
    String? userId,
    String? courseId,
    String? moduleId,
    String? title,
    String? description,
    ReclamationCategory? category,
    ReclamationStatus? status,
    ReclamationPriority? priority,
    int? ratingBefore,
    int? ratingAfter,
    String? attachmentUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
  }) {
    return Reclamation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      moduleId: moduleId ?? this.moduleId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      ratingBefore: ratingBefore ?? this.ratingBefore,
      ratingAfter: ratingAfter ?? this.ratingAfter,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}

class ReclamationResponse {
  final String id;
  final String reclamationId;
  final String responderId;
  final String responseText;
  final bool isAdminResponse;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReclamationResponse({
    required this.id,
    required this.reclamationId,
    required this.responderId,
    required this.responseText,
    required this.isAdminResponse,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReclamationResponse.fromMap(Map<String, dynamic> map) {
    return ReclamationResponse(
      id: map['id'] as String? ?? '',
      reclamationId: map['reclamation_id'] as String? ?? '',
      responderId: map['responder_id'] as String? ?? '',
      responseText: map['response_text'] as String? ?? '',
      isAdminResponse: map['is_admin_response'] as bool? ?? true,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'].toString()) : DateTime.now(),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'].toString()) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reclamation_id': reclamationId,
      'responder_id': responderId,
      'response_text': responseText,
      'is_admin_response': isAdminResponse,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
