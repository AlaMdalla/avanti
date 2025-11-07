class Certificate {
  final String id;
  final String userId;
  final String courseId;
  final int score;
  final DateTime createdAt;

  Certificate({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.score,
    required this.createdAt,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'],
      userId: json['user_id'],
      courseId: json['course_id'],
      score: json['score'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'score': score,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
