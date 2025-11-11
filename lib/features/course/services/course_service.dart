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

  Future<String> uploadPdf(File file, {required String userId}) async {
    try {
      // Validate file exists
      if (!await file.exists()) {
        throw Exception('PDF file does not exist');
      }

      // Validate file size (max 50MB)
      final fileSize = await file.length();
      if (fileSize > 50 * 1024 * 1024) {
        throw Exception('PDF file is too large (max 50MB)');
      }

      final ext = p.extension(file.path);
      if (ext.toLowerCase() != '.pdf') {
        throw Exception('File must be a PDF (got $ext)');
      }

      final filename = '${userId}_${DateTime.now().millisecondsSinceEpoch}$ext';
      final pathInBucket = 'uploads/$filename';

      print('📤 Uploading PDF: $filename');
      print('📁 Bucket: course-pdfs');
      print('📍 Path: $pathInBucket');
      print('📊 Size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');

      // Upload to course-pdfs bucket
      await _sb.storage.from('course-pdfs').upload(
            pathInBucket,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      print('✅ PDF uploaded successfully');

      // Get public URL
      final publicUrl = _sb.storage.from('course-pdfs').getPublicUrl(pathInBucket);
      print('🔗 Public URL: $publicUrl');
      
      return publicUrl;
    } on SocketException catch (e) {
      throw Exception('Network error: ${e.message}. Check your internet connection.');
    } on FormatException catch (e) {
      throw Exception('Invalid bucket name or path: ${e.message}');
    } catch (e) {
      final errorMsg = e.toString();
      
      // Helpful error messages
      if (errorMsg.contains('404') || errorMsg.contains('Not Found')) {
        throw Exception('❌ Bucket "course-pdfs" not found. Create it in Supabase Storage first.');
      } else if (errorMsg.contains('401') || errorMsg.contains('Unauthorized')) {
        throw Exception('❌ Not authenticated. Please log in first.');
      } else if (errorMsg.contains('403') || errorMsg.contains('Permission denied')) {
        throw Exception('❌ Permission denied. Check RLS policies for "course-pdfs" bucket.');
      } else {
        throw Exception('Failed to upload PDF: $e');
      }
    }
  }

  Future<void> deletePdf(String pdfUrl) async {
    try {
      // Extract filename from URL
      final uri = Uri.parse(pdfUrl);
      final pathSegments = uri.pathSegments;
      final filename = pathSegments.isNotEmpty ? pathSegments.last : '';
      
      if (filename.isNotEmpty) {
        await _sb.storage.from('course-pdfs').remove(['course-pdfs/$filename']);
      }
    } catch (e) {
      throw Exception('Failed to delete PDF: $e');
    }
  }
}
