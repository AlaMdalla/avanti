import 'package:flutter/foundation.dart';

@immutable
class Event {
  final String id;
  final String title;
  final String? description;
  final DateTime eventDate;
  final String? location;
  final String? imageUrl;
  final String? categoryId;
  final String createdBy;
  final int? maxAttendees;
  final int? currentAttendees;
  final bool isOnline;
  final String? eventLink;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Event({
    required this.id,
    required this.title,
    required this.eventDate,
    required this.createdBy,
    this.description,
    this.location,
    this.imageUrl,
    this.categoryId,
    this.maxAttendees,
    this.currentAttendees,
    this.isOnline = false,
    this.eventLink,
    this.createdAt,
    this.updatedAt,
  });

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? eventDate,
    String? location,
    String? imageUrl,
    String? categoryId,
    String? createdBy,
    int? maxAttendees,
    int? currentAttendees,
    bool? isOnline,
    String? eventLink,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      createdBy: createdBy ?? this.createdBy,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      currentAttendees: currentAttendees ?? this.currentAttendees,
      isOnline: isOnline ?? this.isOnline,
      eventLink: eventLink ?? this.eventLink,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      eventDate: DateTime.parse(map['event_date'] as String),
      location: map['location'] as String?,
      imageUrl: map['image_url'] as String?,
      categoryId: map['category_id'] as String?,
      createdBy: map['created_by'] as String,
      maxAttendees: map['max_attendees'] as int?,
      currentAttendees: map['current_attendees'] as int?,
      isOnline: (map['is_online'] as bool?) ?? false,
      eventLink: map['event_link'] as String?,
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
      'event_date': eventDate.toIso8601String(),
      'location': location,
      'image_url': imageUrl,
      'category_id': categoryId,
      'created_by': createdBy,
      'max_attendees': maxAttendees,
      'current_attendees': currentAttendees,
      'is_online': isOnline,
      'event_link': eventLink,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get isUpcoming => eventDate.isAfter(DateTime.now());
  bool get isPast => eventDate.isBefore(DateTime.now());
  bool get hasSpace => maxAttendees == null || (currentAttendees ?? 0) < maxAttendees!;
  int get spotsLeft => maxAttendees != null ? maxAttendees! - (currentAttendees ?? 0) : 0;

  @override
  String toString() => 'Event(id: $id, title: $title, eventDate: $eventDate)';
}

class EventInput {
  final String title;
  final String? description;
  final DateTime eventDate;
  final String? location;
  final String? categoryId;
  final int? maxAttendees;
  final bool isOnline;
  final String? eventLink;

  EventInput({
    required this.title,
    required this.eventDate,
    this.description,
    this.location,
    this.categoryId,
    this.maxAttendees,
    this.isOnline = false,
    this.eventLink,
  });

  Map<String, dynamic> toInsert(String createdBy) {
    return {
      'title': title,
      'description': description,
      'event_date': eventDate.toIso8601String(),
      'location': location,
      'category_id': categoryId,
      'created_by': createdBy,
      'max_attendees': maxAttendees,
      'is_online': isOnline,
      'event_link': eventLink,
      'current_attendees': 0,
    };
  }

  Map<String, dynamic> toUpdate() {
    return {
      'title': title,
      'description': description,
      'event_date': eventDate.toIso8601String(),
      'location': location,
      'category_id': categoryId,
      'max_attendees': maxAttendees,
      'is_online': isOnline,
      'event_link': eventLink,
    };
  }
}
