import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reclamation_model.dart';

class ReclamationService {
  final supabase = Supabase.instance.client;

  Future<void> addReclamation({
    required String courseId,
    required String title,
    required String description,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    await supabase.from('reclamations').insert({
      'user_id': user.id,
      'course_id': courseId,
      'title': title,
      'description': description,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Reclamation>> fetchUserReclamations() async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    final response = await supabase
        .from('reclamations')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (response as List)
        .map((data) => Reclamation.fromJson(data))
        .toList();
  }
}
