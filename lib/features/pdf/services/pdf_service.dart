import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

class PdfService {
  final SupabaseClient _supabase;
  static const String bucket = 'pdfs';

  PdfService({SupabaseClient? client})
      : _supabase = client ?? Supabase.instance.client;

  /// Upload a PDF file to the bucket
  Future<String> uploadPdf(
    File pdfFile, {
    required String userId,
    String? customName,
  }) async {
    try {
      final fileExt = p.extension(pdfFile.path); // Gets .pdf
      final fileName = customName ?? 
          '${userId}_${DateTime.now().millisecondsSinceEpoch}$fileExt';
      final pathInBucket = 'uploads/$fileName';

      // Upload the file
      await _supabase.storage.from(bucket).upload(
            pathInBucket,
            pdfFile,
            fileOptions: const FileOptions(upsert: true),
          );

      // Get public URL
      final publicUrl = _supabase.storage.from(bucket).getPublicUrl(pathInBucket);
      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload PDF: $e');
    }
  }

  /// Download a PDF file from the bucket
  Future<File> downloadPdf(String filePath) async {
    try {
      final data = await _supabase.storage.from(bucket).download(filePath);
      
      // Save to temporary directory
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/${p.basename(filePath)}');
      await tempFile.writeAsBytes(data);
      
      return tempFile;
    } catch (e) {
      throw Exception('Failed to download PDF: $e');
    }
  }

  /// Delete a PDF file from the bucket
  Future<void> deletePdf(String filePath) async {
    try {
      await _supabase.storage.from(bucket).remove([filePath]);
    } catch (e) {
      throw Exception('Failed to delete PDF: $e');
    }
  }

  /// List all PDFs in a folder
  Future<List<FileObject>> listPdfs(String folderPath) async {
    try {
      final files = await _supabase.storage.from(bucket).list(path: folderPath);
      return files;
    } catch (e) {
      throw Exception('Failed to list PDFs: $e');
    }
  }

  /// Get public URL for a PDF (without uploading)
  String getPublicUrl(String filePath) {
    return _supabase.storage.from(bucket).getPublicUrl(filePath);
  }
}
