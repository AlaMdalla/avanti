class Lesson {
  final String id;
  final String module_id;
  final String title;
  final String type; // video, pdf, quiz
  final String description;
  final String? contentUrl;
  final int? duration; // en secondes
  final DateTime? updatedAt;

  Lesson({
    required this.id,
    required this.module_id,
    required this.title,
    required this.type,
    required this.description,
    this.contentUrl,
    this.duration,
    this.updatedAt,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        id: json['id'],
        module_id: json['module_id'],
        title: json['title'],
        type: json['type'] ?? 'quiz',
        description: json['description'],
        contentUrl: json['content_url'],
        duration: json['duration'],
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : null,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'module_id': module_id,
        'title': title,
        'type': type,
        'description': description,
        'content_url': contentUrl,
        'duration': duration,
        'updated_at': updatedAt?.toIso8601String(),
      };
}
