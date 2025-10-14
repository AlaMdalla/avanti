import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/lesson.dart';

abstract class LessonRemoteDataSource {
  Future<List<Lesson>> fetchLessons(String module_id);
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
        .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
