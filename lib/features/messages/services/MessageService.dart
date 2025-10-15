import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message.dart';

class MessageService {
  final _supabase = Supabase.instance.client;

  // Send a message
  Future<Message?> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
    String? conversationId,
  }) async {
    try {
      final response = await _supabase.from('messages').insert({
        'sender_id': senderId,
        'receiver_id': receiverId,
        'content': content,
        'timestamp': DateTime.now().toIso8601String(),
        'conversation_id': conversationId,
      }).select().single();

      return Message.fromJson(response);
    } catch (e) {
      print('Error sending message: $e');
      return null;
    }
  }

  // Get messages for a conversation (between two users)
  Future<List<Message>> getMessages(String userId1, String userId2) async {
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .or('and(sender_id.eq.$userId1,receiver_id.eq.$userId2),and(sender_id.eq.$userId2,receiver_id.eq.$userId1)')
          .order('timestamp', ascending: true);

      return response.map((json) => Message.fromJson(json)).toList();
    } catch (e) {
      print('Error getting messages: $e');
      return [];
    }
  }

  // Listen for real-time updates (e.g., new messages)
 Stream<List<Message>> listenForMessages(String userId1, String userId2) {
  return _supabase
      .from('messages')
      .stream(primaryKey: ['id'])
      .map((data) => data
          .where((json) =>
              (json['sender_id'] == userId1 && json['receiver_id'] == userId2) ||
              (json['sender_id'] == userId2 && json['receiver_id'] == userId1))
          .map((json) => Message.fromJson(json))
          .toList());
}
}