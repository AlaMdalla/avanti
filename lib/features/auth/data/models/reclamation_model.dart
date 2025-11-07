class Reclamation {
  final String id;
  final String userId;
  final String? courseId;
  final String title;
  final String description;
  final String status;
  final DateTime createdAt;

  Reclamation({
    required this.id,
    required this.userId,
    this.courseId,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  factory Reclamation.fromJson(Map<String, dynamic> json) {
    return Reclamation(
      id: json['id'],
      userId: json['user_id'],
      courseId: json['course_id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'title': title,
      'description': description,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
