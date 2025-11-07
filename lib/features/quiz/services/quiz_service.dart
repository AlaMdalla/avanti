import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/quiz_models.dart';

class QuizService {
  final SupabaseClient _sb;
  static const String quizzesTable = 'quizzes';
  static const String questionsTable = 'quiz_questions';
  static const String optionsTable = 'quiz_options';
  static const String attemptsTable = 'quiz_attempts';

  QuizService({SupabaseClient? client}) : _sb = client ?? Supabase.instance.client;

  Future<List<Quiz>> listByCourse(String courseId) async {
    final raw = await _sb
        .from(quizzesTable)
        .select()
        .eq('course_id', courseId)
        .order('created_at', ascending: false);
    final list = (raw as List).cast<Map<String, dynamic>>();
    return list.map(Quiz.fromMap).toList();
  }

  Future<QuizWithQuestions> getQuizWithQuestions(String quizId) async {
    final quizMap = await _sb.from(quizzesTable).select().eq('id', quizId).maybeSingle();
    if (quizMap == null) {
      throw Exception('Quiz not found');
    }
    final quiz = Quiz.fromMap(quizMap as Map<String, dynamic>);

    final qRaw = await _sb
        .from(questionsTable)
        .select()
        .eq('quiz_id', quizId)
        .order('order', ascending: true);
    final questions = (qRaw as List)
        .cast<Map<String, dynamic>>()
        .map(QuizQuestion.fromMap)
        .toList();

    if (questions.isEmpty) {
      return QuizWithQuestions(quiz: quiz, questions: const [], optionsByQuestionId: const {});
    }

    final ids = questions.map((e) => e.id).toList();
  // Postgrest 'in' operator manual construction (since in_ helper unavailable)
  final questionIdList = ids.map((e) => '"$e"').join(',');
  final oRaw = await _sb
    .from(optionsTable)
    .select()
    .filter('question_id', 'in', '($questionIdList)');
    final options = (oRaw as List)
        .cast<Map<String, dynamic>>()
        .map(QuizOption.fromMap)
        .toList();

    final map = <String, List<QuizOption>>{};
    for (final q in questions) {
      map[q.id] = options.where((o) => o.questionId == q.id).toList();
    }

    return QuizWithQuestions(
      quiz: quiz,
      questions: questions,
      optionsByQuestionId: map,
    );
  }

  Future<Quiz> createQuiz({
    required String courseId,
    required String title,
    String? description,
    int timeLimitSeconds = 0,
    String? instructorId,
  }) async {
    final inserted = await _sb
        .from(quizzesTable)
        .insert({
          'course_id': courseId,
          if (instructorId != null) 'instructor_id': instructorId,
          'title': title,
          'description': description,
          'time_limit_seconds': timeLimitSeconds,
        })
        .select()
        .single();
    return Quiz.fromMap(inserted as Map<String, dynamic>);
  }

  Future<QuizAttempt> submitAttempt({
    required String quizId,
    required String userId,
    required Map<String, String> selectedOptionIdByQuestionId,
  }) async {
    if (selectedOptionIdByQuestionId.isEmpty) {
      throw Exception('No answers selected');
    }
    final selectedIds = selectedOptionIdByQuestionId.values.toSet().toList();
  final selectedIdList = selectedIds.map((e) => '"$e"').join(',');
  final raw = await _sb
    .from(optionsTable)
    .select('id, is_correct')
    .filter('id', 'in', '($selectedIdList)');
    final list = (raw as List).cast<Map<String, dynamic>>();
    final correct = list.where((m) => (m['is_correct'] as bool?) == true).length;
    final total = selectedOptionIdByQuestionId.length;

    final attemptMap = await _sb
        .from(attemptsTable)
        .insert({
          'quiz_id': quizId,
          'user_id': userId,
          'correct_count': correct,
          'total': total,
        })
        .select()
        .single();

    return QuizAttempt.fromMap(attemptMap as Map<String, dynamic>);
  }

  // Question & Option management
  Future<QuizQuestion> createQuestion({
    required String quizId,
    required String text,
    int order = 0,
  }) async {
    final inserted = await _sb
        .from(questionsTable)
        .insert({
          'quiz_id': quizId,
          'text': text,
          'order': order,
        })
        .select()
        .single();
    return QuizQuestion.fromMap(inserted as Map<String, dynamic>);
  }

  Future<List<QuizOption>> createOptionsBulk({
    required String questionId,
    required List<Map<String, dynamic>> options, // {text, is_correct}
  }) async {
    if (options.isEmpty) return [];
    final prepared = options
        .map((o) => {
              'question_id': questionId,
              'text': o['text'],
              'is_correct': o['is_correct'] ?? false,
            })
        .toList();
    final raw = await _sb
        .from(optionsTable)
        .insert(prepared)
        .select();
    final list = (raw as List).cast<Map<String, dynamic>>();
    return list.map(QuizOption.fromMap).toList();
  }

  Future<void> deleteQuestion(String questionId) async {
    await _sb.from(questionsTable).delete().eq('id', questionId);
  }

  Future<void> deleteOption(String optionId) async {
    await _sb.from(optionsTable).delete().eq('id', optionId);
  }
}
