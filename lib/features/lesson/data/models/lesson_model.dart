class LessonModel extends Lesson {
  LessonModel({
    required super.id,
    required super.module_id,
    required super.title,
    required super.type,
    required super.description,
    super.contentUrl,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) => LessonModel(
        id: json['id'],
        module_id: json['module_id'],
        title: json['title'],
        type: json['type'] ?? 'video', 
        description: json['description'],
        contentUrl: json['contentUrl'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'module_id': module_id,
        'title': title,
        'type': type,
        'description': description,
        'contentUrl': contentUrl,
      };
}
