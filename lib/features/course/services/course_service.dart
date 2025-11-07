import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;
import '../models/course.dart';

class CourseService {
  final SupabaseClient _sb;
  static const String table = 'courses';
  static const String bucket = 'avatars';

  CourseService({SupabaseClient? client}) : _sb = client ?? Supabase.instance.client;

  Future<List<Course>> list({int limit = 50, int offset = 0}) async {
    final data = await _sb.from(table)
        .select()
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
  final list = data as List<dynamic>;
  return list.map((e) => Course.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<Course> getById(String id) async {
    final data = await _sb.from(table).select().eq('id', id).maybeSingle();
    if (data == null) {
      throw Exception('Course not found');
    }
  return Course.fromMap(data);
  }

  Future<Course> create(CourseInput input, {required String instructorId}) async {
    final inserted = await _sb
        .from(table)
        .insert(input.toInsert(instructorId))
        .select()
        .single();
  return Course.fromMap(inserted);
  }

  Future<Course> update(String id, CourseInput input) async {
    final updated = await _sb
        .from(table)
        .update(input.toUpdate())
        .eq('id', id)
        .select()
        .single();
  return Course.fromMap(updated);
  }

  Future<void> delete(String id) async {
    await _sb.from(table).delete().eq('id', id);
  }
    
  Future<String> uploadImage(File file, {required String userId}) async {
    final ext = p.extension(file.path);
    final filename = '${userId}_${DateTime.now().millisecondsSinceEpoch}$ext';
    final pathInBucket = 'courses/$filename';

    await _sb.storage.from(bucket).upload(
          pathInBucket,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

    final publicUrl = _sb.storage.from(bucket).getPublicUrl(pathInBucket);
    return publicUrl;
  }
}
