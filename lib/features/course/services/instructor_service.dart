import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;
import '../models/instructor.dart';

class InstructorService {
  final SupabaseClient _sb;
  static const String table = 'instructors';
  static const String bucket = 'avatars';

  InstructorService({SupabaseClient? client})
      : _sb = client ?? Supabase.instance.client;

  /// Get all instructors with pagination
  Future<List<Instructor>> list({int limit = 50, int offset = 0}) async {
    final data = await _sb.from(table)
        .select()
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    final list = data as List<dynamic>;
    return list.map((e) => Instructor.fromMap(e as Map<String, dynamic>)).toList();
  }

  /// Get instructor by ID
  Future<Instructor> getById(String id) async {
    final data = await _sb.from(table).select().eq('id', id).maybeSingle();
    if (data == null) {
      throw Exception('Instructor not found');
    }
    return Instructor.fromMap(data);
  }

  /// Get instructor by name (optional for search)
  Future<List<Instructor>> getByName(String name) async {
    final data = await _sb
        .from(table)
        .select()
        .ilike('name', '%$name%')
        .order('created_at', ascending: false);
    final list = data as List<dynamic>;
    return list.map((e) => Instructor.fromMap(e as Map<String, dynamic>)).toList();
  }

  /// Create a new instructor
  Future<Instructor> create(InstructorInput input) async {
    final inserted = await _sb
        .from(table)
        .insert(input.toInsert())
        .select()
        .single();
    return Instructor.fromMap(inserted);
  }

  /// Update an instructor
  Future<Instructor> update(String id, InstructorInput input) async {
    final updated = await _sb
        .from(table)
        .update(input.toUpdate())
        .eq('id', id)
        .select()
        .single();
    return Instructor.fromMap(updated);
  }

  /// Delete an instructor
  Future<void> delete(String id) async {
    await _sb.from(table).delete().eq('id', id);
  }

  /// Upload instructor avatar image
  Future<String> uploadAvatar(File file, {required String instructorId}) async {
    try {
      // Validate file exists
      if (!await file.exists()) {
        throw Exception('Avatar file does not exist');
      }

      // Validate file size (max 10MB)
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        throw Exception('Avatar file is too large (max 10MB)');
      }

      // Validate file extension
      final ext = p.extension(file.path).toLowerCase();
      const allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
      if (!allowedExtensions.contains(ext)) {
        throw Exception('File must be an image (jpg, png, gif, webp)');
      }

      final filename = '${instructorId}_${DateTime.now().millisecondsSinceEpoch}$ext';
      final pathInBucket = 'instructors/$filename';

      print('📤 Uploading instructor avatar: $filename');
      print('📁 Bucket: $bucket');
      print('📍 Path: $pathInBucket');
      print('📊 Size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');

      // Upload to avatars bucket
      await _sb.storage.from(bucket).upload(
            pathInBucket,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = _sb.storage.from(bucket).getPublicUrl(pathInBucket);
      print('✅ Avatar uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('❌ Error uploading avatar: $e');
      rethrow;
    }
  }

  /// Delete instructor avatar
  Future<void> deleteAvatar(String instructorId) async {
    try {
      final files = await _sb.storage.from(bucket).list(path: 'instructors/');
      final filesToDelete = files
          .where((file) => file.name.startsWith(instructorId))
          .map((file) => 'instructors/${file.name}')
          .toList();

      if (filesToDelete.isNotEmpty) {
        await _sb.storage.from(bucket).remove(filesToDelete);
        print('✅ Avatar deleted successfully');
      }
    } catch (e) {
      print('❌ Error deleting avatar: $e');
      rethrow;
    }
  }
}
