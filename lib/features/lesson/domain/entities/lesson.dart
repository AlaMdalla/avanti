class Lesson {
  final String id;
  final String module_id;
  final String title;
  final String type; // video, quiz, document, pdf
  final String description;
  final String? contentUrl;

  Lesson({
    required this.id,
    required this.module_id,
    required this.title,
    required this.type,
    required this.description,
    this.contentUrl,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
      id: json['id'],
      module_id: json['module_id'],
      title: json['title'],
      type: json['type'] ?? 'quiz',
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
