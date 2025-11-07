import 'package:flutter/foundation.dart';

@immutable
class Quiz {
  final String id;
  final String courseId;
  final String title;
  final String? description;
  final int timeLimitSeconds; // 0 = no limit
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Quiz({
    required this.id,
    required this.courseId,
    required this.title,
    this.description,
    this.timeLimitSeconds = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory Quiz.fromMap(Map<String, dynamic> map) => Quiz(
        id: map['id'] as String,
        courseId: map['course_id'] as String,
        title: map['title'] as String,
        description: map['description'] as String?,
        timeLimitSeconds: (map['time_limit_seconds'] as int?) ?? 0,
        createdAt: map['created_at'] != null
            ? DateTime.tryParse(map['created_at'] as String)
            : null,
        updatedAt: map['updated_at'] != null
            ? DateTime.tryParse(map['updated_at'] as String)
            : null,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'course_id': courseId,
        'title': title,
        'description': description,
        'time_limit_seconds': timeLimitSeconds,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}

@immutable
class QuizQuestion {
  final String id;
  final String quizId;
  final String text;
  final int order;

  const QuizQuestion({
    required this.id,
    required this.quizId,
    required this.text,
    required this.order,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) => QuizQuestion(
        id: map['id'] as String,
        quizId: map['quiz_id'] as String,
        text: map['text'] as String,
        order: (map['order'] as int? ?? 0),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'quiz_id': quizId,
        'text': text,
        'order': order,
      };
}

@immutable
class QuizOption {
  final String id;
  final String questionId;
  final String text;
  final bool isCorrect;

  const QuizOption({
    required this.id,
    required this.questionId,
    required this.text,
    required this.isCorrect,
  });

  factory QuizOption.fromMap(Map<String, dynamic> map) => QuizOption(
        id: map['id'] as String,
        questionId: map['question_id'] as String,
        text: map['text'] as String,
        isCorrect: (map['is_correct'] as bool?) ?? false,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'question_id': questionId,
        'text': text,
        'is_correct': isCorrect,
      };
}

@immutable
class QuizAttempt {
  final String id;
  final String quizId;
  final String userId;
  final int correctCount;
  final int total;
  final DateTime createdAt;

  const QuizAttempt({
    required this.id,
    required this.quizId,
    required this.userId,
    required this.correctCount,
    required this.total,
    required this.createdAt,
  });

  factory QuizAttempt.fromMap(Map<String, dynamic> map) => QuizAttempt(
        id: map['id'] as String,
        quizId: map['quiz_id'] as String,
        userId: map['user_id'] as String,
        correctCount: map['correct_count'] as int,
        total: map['total'] as int,
        createdAt: DateTime.tryParse(map['created_at'] as String) ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'quiz_id': quizId,
        'user_id': userId,
        'correct_count': correctCount,
        'total': total,
        'created_at': createdAt.toIso8601String(),
      };
}

@immutable
class QuizWithQuestions {
  final Quiz quiz;
  final List<QuizQuestion> questions;
  final Map<String, List<QuizOption>> optionsByQuestionId;

  const QuizWithQuestions({
    required this.quiz,
    required this.questions,
    required this.optionsByQuestionId,
  });
}
