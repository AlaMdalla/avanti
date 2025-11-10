import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reclamation.dart';

class ReclamationService {
  final _supabase = Supabase.instance.client;

  // Create a new reclamation
  Future<Reclamation> createReclamation({
    required String title,
    required String description,
    required String category,
    String? courseId,
    String? moduleId,
    String? priority,
    int? ratingBefore,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('reclamations')
          .insert({
            'user_id': userId,
            'title': title,
            'description': description,
            'category': category,
            'course_id': courseId,
            'module_id': moduleId,
            'priority': priority ?? 'medium',
            'rating_before': ratingBefore,
            'status': 'open',
          })
          .select()
          .single();

      return Reclamation.fromMap(response);
    } catch (e) {
      print('Error creating reclamation: $e');
      rethrow;
    }
  }

  // Get all reclamations for current user
  Future<List<Reclamation>> getUserReclamations() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('reclamations')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final reclamations = response is List ? response : [response];
      return reclamations
          .map((r) => Reclamation.fromMap(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching user reclamations: $e');
      return [];
    }
  }

  // Get reclamation by ID
  Future<Reclamation?> getReclamationById(String id) async {
    try {
      final response = await _supabase
          .from('reclamations')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return Reclamation.fromMap(response);
    } catch (e) {
      print('Error fetching reclamation: $e');
      return null;
    }
  }

  // Update reclamation
  Future<Reclamation> updateReclamation({
    required String id,
    String? title,
    String? description,
    String? category,
    String? priority,
    int? ratingAfter,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (category != null) updateData['category'] = category;
      if (priority != null) updateData['priority'] = priority;
      if (ratingAfter != null) updateData['rating_after'] = ratingAfter;
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('reclamations')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      return Reclamation.fromMap(response);
    } catch (e) {
      print('Error updating reclamation: $e');
      rethrow;
    }
  }

  // Update reclamation status (admin only)
  Future<void> updateReclamationStatus({
    required String reclamationId,
    required String newStatus,
    String? changeReason,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Call the stored procedure
      await _supabase
          .rpc('update_reclamation_status', params: {
            'p_reclamation_id': reclamationId,
            'p_new_status': newStatus,
            'p_changed_by': userId,
            'p_change_reason': changeReason,
          });
    } catch (e) {
      print('Error updating reclamation status: $e');
      rethrow;
    }
  }

  // Add response to reclamation
  Future<ReclamationResponse> addResponse({
    required String reclamationId,
    required String responseText,
    bool isAdminResponse = true,
  }) async {
    try {
      final responderId = _supabase.auth.currentUser?.id;
      if (responderId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('reclamation_responses')
          .insert({
            'reclamation_id': reclamationId,
            'responder_id': responderId,
            'response_text': responseText,
            'is_admin_response': isAdminResponse,
          })
          .select()
          .single();

      return ReclamationResponse.fromMap(response);
    } catch (e) {
      print('Error adding response: $e');
      rethrow;
    }
  }

  // Get responses for a reclamation
  Future<List<ReclamationResponse>> getReclamationResponses(
      String reclamationId) async {
    try {
      final response = await _supabase
          .from('reclamation_responses')
          .select()
          .eq('reclamation_id', reclamationId)
          .order('created_at', ascending: true);

      final responses = response is List ? response : [response];
      return responses
          .map((r) => ReclamationResponse.fromMap(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching responses: $e');
      return [];
    }
  }

  // Get all reclamations (admin only)
  Future<List<Reclamation>> getAllReclamations({
    String? status,
    String? priority,
  }) async {
    try {
      var query = _supabase.from('reclamations').select();

      if (status != null) {
        query = query.eq('status', status);
      }
      if (priority != null) {
        query = query.eq('priority', priority);
      }

      final response = await query.order('created_at', ascending: false);

      final reclamations = response is List ? response : [response];
      return reclamations
          .map((r) => Reclamation.fromMap(r as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching all reclamations: $e');
      return [];
    }
  }

  // Get reclamation statistics
  Future<Map<String, dynamic>> getReclamationStats() async {
    try {
      final response = await _supabase.rpc('get_reclamation_counts');
      
      final stats = <String, int>{};
      if (response is List) {
        for (final item in response) {
          stats[item['status']] = item['count'] as int;
        }
      }
      return stats;
    } catch (e) {
      print('Error fetching reclamation stats: $e');
      return {};
    }
  }

  // Close reclamation
  Future<void> closeReclamation({
    required String reclamationId,
    String? changeReason,
  }) async {
    await updateReclamationStatus(
      reclamationId: reclamationId,
      newStatus: 'closed',
      changeReason: changeReason,
    );
  }
}
