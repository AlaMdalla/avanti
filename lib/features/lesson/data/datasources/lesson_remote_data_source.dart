import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/lesson.dart';

abstract class LessonRemoteDataSource {
  Future<List<Lesson>> fetchLessons(String module_id);
  Future<void> addLesson(Lesson lesson);
  Future<void> deleteLesson(String lessonId);
  Future<void> updateLesson(Lesson lesson); // <-- Ajouté
}

class LessonRemoteDataSourceImpl implements LessonRemoteDataSource {
  final SupabaseClient client;

  LessonRemoteDataSourceImpl(this.client);

  @override
  Future<List<Lesson>> fetchLessons(String module_id) async {
    final response = await client
        .from('lessons')
        .select()
        .eq('module_id', module_id);

    return (response as List)
        .map((data) => Lesson.fromJson(data as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> addLesson(Lesson lesson) async {
    await client.from('lessons').insert(lesson.toMap());
  }

  @override
  Future<void> deleteLesson(String lessonId) async {
    await client.from('lessons').delete().eq('id', lessonId);
  }

  @override
  Future<void> updateLesson(Lesson lesson) async {
    await client.from('lessons')
        .update(lesson.toMap())
        .eq('id', lesson.id);
  }
}