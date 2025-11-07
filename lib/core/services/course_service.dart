import 'package:supabase_flutter/supabase_flutter.dart';

class CourseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getCourses() async {
    final response = await _client.from('courses').select();
    return List<Map<String, dynamic>>.from(response);
  }
}
