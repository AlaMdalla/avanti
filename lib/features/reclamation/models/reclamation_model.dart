class Reclamation {
  final String id;
  final String userId;
  final String courseId;
  final String title;
  final String description;
  final DateTime createdAt;

  Reclamation({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  factory Reclamation.fromJson(Map<String, dynamic> json) {
    return Reclamation(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      courseId: json['course_id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

