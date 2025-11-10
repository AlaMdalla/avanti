import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/course.dart';

class CourseRecommendationService {
  CourseRecommendationService({String? apiKey})
      : _apiKey = apiKey ?? (dotenv.env['HF_API_KEY'] ?? 'HF_API_KEY_PLACEHOLDER');

  final String _apiKey;
  
  static const String _chatEndpoint = 'https://router.huggingface.co/v1/chat/completions';
  static const String _embeddingEndpoint = 'https://api-inference.huggingface.co/pipeline/feature-extraction';
  static const String _model = 'swiss-ai/Apertus-8B-Instruct-2509:publicai';

  Future<List<CourseRecommendation>> recommendCourses({
    required String userQuery,
    required List<Course> availableCourses,
    int limit = 5,
  }) async {
    if (availableCourses.isEmpty) return [];
    try {
      final queryEmbedding = await _getEmbedding(userQuery);
      final recommendations = <CourseRecommendation>[];
      
      for (final course in availableCourses) {
        final courseText = '${course.title} ${course.description ?? ''}';
        final courseEmbedding = await _getEmbedding(courseText);
        final score = _cosineSimilarity(queryEmbedding, courseEmbedding);
        recommendations.add(CourseRecommendation(
          course: course,
          score: score,
          reason: 'Matches your interest',
        ));
      }

      recommendations.sort((a, b) => b.score.compareTo(a.score));
      return recommendations.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to recommend courses: $e');
    }
  }

  Future<AIRecommendationResult> getAIRecommendations({
    required String userInterests,
    required List<Course> availableCourses,
  }) async {
    if (availableCourses.isEmpty) {
      return AIRecommendationResult(recommendations: [], explanation: 'No courses available');
    }

    try {
      final courseList = availableCourses
          .map((c) => '- ${c.title}: ${c.description ?? "No description"}')
          .join('\n');

      final messages = [
        {
          'role': 'system',
          'content': 'You are an educational advisor. Recommend courses based on user interests.',
        },
        {
          'role': 'user',
          'content': 'Based on my interests in "$userInterests", which courses would you recommend?\n\n$courseList',
        }
      ];

      final response = await _chatCompletion(messages);
      final recommendations = <CourseRecommendation>[];
      
      for (final course in availableCourses) {
        if (response.toLowerCase().contains(course.title.toLowerCase())) {
          recommendations.add(CourseRecommendation(
            course: course,
            score: 0.9,
            reason: 'Recommended based on your interests',
          ));
        }
      }

      return AIRecommendationResult(recommendations: recommendations, explanation: response);
    } catch (e) {
      throw Exception('Failed to get AI recommendations: $e');
    }
  }

  Future<List<CourseRecommendation>> getSimilarCourses({
    required Course referenceCourse,
    required List<Course> availableCourses,
    int limit = 5,
  }) async {
    final otherCourses = availableCourses.where((c) => c.id != referenceCourse.id).toList();
    if (otherCourses.isEmpty) return [];

    try {
      final referenceText = '${referenceCourse.title} ${referenceCourse.description ?? ''}';
      final referenceEmbedding = await _getEmbedding(referenceText);
      final recommendations = <CourseRecommendation>[];

      for (final course in otherCourses) {
        final courseText = '${course.title} ${course.description ?? ''}';
        final courseEmbedding = await _getEmbedding(courseText);
        final score = _cosineSimilarity(referenceEmbedding, courseEmbedding);
        recommendations.add(CourseRecommendation(
          course: course,
          score: score,
          reason: 'Similar to ${referenceCourse.title}',
        ));
      }

      recommendations.sort((a, b) => b.score.compareTo(a.score));
      return recommendations.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to get similar courses: $e');
    }
  }

  Future<List<double>> _getEmbedding(String text) async {
    try {
      final resp = await http.post(
        Uri.parse(_embeddingEndpoint),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'inputs': text}),
      );

      if (resp.statusCode != 200) {
        throw Exception('Embedding error ${resp.statusCode}');
      }

      final data = jsonDecode(resp.body);
      if (data is List && data.isNotEmpty) {
        final embedding = data is List<List<dynamic>> ? data.first : data;
        return (embedding as List<dynamic>).map((e) => (e as num).toDouble()).toList();
      }
      throw Exception('Invalid embedding response');
    } catch (e) {
      throw Exception('Failed to get embedding: $e');
    }
  }

  Future<String> _chatCompletion(List<Map<String, String>> messages) async {
    try {
      final resp = await http.post(
        Uri.parse(_chatEndpoint),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'max_tokens': 512,
          'temperature': 0.7,
        }),
      );

      if (resp.statusCode >= 400) {
        throw Exception('Chat error ${resp.statusCode}');
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final choices = data['choices'] as List?;
      if (choices == null || choices.isEmpty) throw Exception('No choices');
      final msg = choices.first['message'] as Map<String, dynamic>?;
      return (msg?['content'] as String?)?.trim() ?? '';
    } catch (e) {
      throw Exception('Failed to get chat completion: $e');
    }
  }

  double _cosineSimilarity(List<double> a, List<double> b) {
    if (a.isEmpty || b.isEmpty || a.length != b.length) return 0.0;

    double dotProduct = 0.0, normA = 0.0, normB = 0.0;
    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    normA = normA > 0 ? sqrt(normA) : 1.0;
    normB = normB > 0 ? sqrt(normB) : 1.0;
    return dotProduct / (normA * normB);
  }
}

class CourseRecommendation {
  final Course course;
  final double score;
  final String reason;

  CourseRecommendation({
    required this.course,
    required this.score,
    required this.reason,
  });

  @override
  String toString() => 'CourseRecommendation(${course.title}, score: ${(score * 100).toStringAsFixed(1)}%, reason: $reason)';
}

class AIRecommendationResult {
  final List<CourseRecommendation> recommendations;
  final String explanation;

  AIRecommendationResult({
    required this.recommendations,
    required this.explanation,
  });
}
