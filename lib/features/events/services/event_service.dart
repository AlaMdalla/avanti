import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;
import '../models/event.dart';

class EventService {
  final SupabaseClient _sb;
  static const String table = 'events';
  static const String bucket = 'avatars';

  EventService({SupabaseClient? client}) : _sb = client ?? Supabase.instance.client;

  Future<List<Event>> list({int limit = 50, int offset = 0}) async {
    final data = await _sb.from(table)
        .select()
        .order('event_date', ascending: true)
        .range(offset, offset + limit - 1);
    final list = data as List<dynamic>;
    return list.map((e) => Event.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<List<Event>> listUpcoming({int limit = 50}) async {
    final now = DateTime.now().toIso8601String();
    final data = await _sb.from(table)
        .select()
        .gte('event_date', now)
        .order('event_date', ascending: true)
        .limit(limit);
    final list = data as List<dynamic>;
    return list.map((e) => Event.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<List<Event>> listPast({int limit = 50}) async {
    final now = DateTime.now().toIso8601String();
    final data = await _sb.from(table)
        .select()
        .lt('event_date', now)
        .order('event_date', ascending: false)
        .limit(limit);
    final list = data as List<dynamic>;
    return list.map((e) => Event.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<List<Event>> listByCategory(String categoryId, {int limit = 50}) async {
    final data = await _sb.from(table)
        .select()
        .eq('category_id', categoryId)
        .order('event_date', ascending: true)
        .limit(limit);
    final list = data as List<dynamic>;
    return list.map((e) => Event.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<List<Event>> searchEvents(String query, {int limit = 50}) async {
    final data = await _sb.from(table)
        .select()
        .ilike('title', '%$query%')
        .order('event_date', ascending: true)
        .limit(limit);
    final list = data as List<dynamic>;
    return list.map((e) => Event.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<Event> getById(String id) async {
    final data = await _sb.from(table).select().eq('id', id).maybeSingle();
    if (data == null) {
      throw Exception('Event not found');
    }
    return Event.fromMap(data);
  }

  Future<Event> create(EventInput input, {required String userId}) async {
    final inserted = await _sb
        .from(table)
        .insert(input.toInsert(userId))
        .select()
        .single();
    return Event.fromMap(inserted);
  }

  Future<Event> update(String id, EventInput input) async {
    final updated = await _sb
        .from(table)
        .update(input.toUpdate())
        .eq('id', id)
        .select()
        .single();
    return Event.fromMap(updated);
  }

  Future<void> delete(String id) async {
    await _sb.from(table).delete().eq('id', id);
  }

  Future<String> uploadImage(File file, {required String userId}) async {
    try {
      if (!await file.exists()) {
        throw Exception('Image file does not exist');
      }

      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        throw Exception('Image file is too large (max 10MB)');
      }

      final ext = p.extension(file.path);
      final filename = '${userId}_event_${DateTime.now().millisecondsSinceEpoch}$ext';
      final pathInBucket = 'events/$filename';

      await _sb.storage.from(bucket).upload(
            pathInBucket,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = _sb.storage.from(bucket).getPublicUrl(pathInBucket);
      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      if (pathSegments.length >= 2) {
        final filename = pathSegments.sublist(pathSegments.length - 2).join('/');
        await _sb.storage.from(bucket).remove([filename]);
      }
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  // Register user for an event
  Future<void> registerForEvent(String eventId, String userId) async {
    try {
      // Check if already registered
      final existing = await _sb
          .from('event_attendees')
          .select()
          .eq('event_id', eventId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        throw Exception('You are already registered for this event');
      }

      // Add attendee
      await _sb.from('event_attendees').insert({
        'event_id': eventId,
        'user_id': userId,
        'registered_at': DateTime.now().toIso8601String(),
      });

      // Update current attendees count
      final event = await getById(eventId);
      final newCount = (event.currentAttendees ?? 0) + 1;
      await _sb.from(table).update({'current_attendees': newCount}).eq('id', eventId);
    } catch (e) {
      throw Exception('Failed to register for event: $e');
    }
  }

  // Unregister user from an event
  Future<void> unregisterFromEvent(String eventId, String userId) async {
    try {
      await _sb.from('event_attendees')
          .delete()
          .eq('event_id', eventId)
          .eq('user_id', userId);

      // Update current attendees count
      final event = await getById(eventId);
      final newCount = ((event.currentAttendees ?? 0) - 1).clamp(0, double.infinity).toInt();
      await _sb.from(table).update({'current_attendees': newCount}).eq('id', eventId);
    } catch (e) {
      throw Exception('Failed to unregister from event: $e');
    }
  }

  // Check if user is registered
  Future<bool> isUserRegistered(String eventId, String userId) async {
    try {
      final result = await _sb
          .from('event_attendees')
          .select()
          .eq('event_id', eventId)
          .eq('user_id', userId)
          .maybeSingle();
      return result != null;
    } catch (e) {
      return false;
    }
  }

  // Get event attendees
  Future<List<Map<String, dynamic>>> getEventAttendees(String eventId) async {
    try {
      final data = await _sb
          .from('event_attendees')
          .select('*, users(*)')
          .eq('event_id', eventId)
          .order('registered_at', ascending: false);
      return data as List<Map<String, dynamic>>;
    } catch (e) {
      throw Exception('Failed to fetch attendees: $e');
    }
  }
}
