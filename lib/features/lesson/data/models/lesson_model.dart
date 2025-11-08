import '../../domain/entities/lesson.dart';

class LessonModel extends Lesson {
  LessonModel({
    required super.id,
    required super.module_id,
    required super.title,
    required super.type,
    required super.description,
    super.contentUrl,
    super.duration,
    super.updatedAt,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) =>
      LessonModel(
        id: json['id'],
        module_id: json['module_id'],
        title: json['title'],
        type: json['type'] ?? 'video',
        description: json['description'],
        contentUrl: json['content_url'],
        duration: json['duration'],
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : null,
      );

  Map<String, dynamic> toJson() => toMap();
}