import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/pdf_service.dart';

class PdfBrowserScreen extends StatefulWidget {
  const PdfBrowserScreen({Key? key}) : super(key: key);

  @override
  State<PdfBrowserScreen> createState() => _PdfBrowserScreenState();
}

class _PdfBrowserScreenState extends State<PdfBrowserScreen> {
  late PdfService _pdfService;
  List<FileObject> _pdfs = [];
  bool _loading = false;
  String? _uploadedPdfUrl;

  @override
  void initState() {
    super.initState();
    _pdfService = PdfService();
    _loadPdfs();
  }

  Future<void> _loadPdfs() async {
    setState(() => _loading = true);
    try {
      final pdfs = await _pdfService.listPdfs('uploads');
      setState(() => _pdfs = pdfs);
    } catch (e) {
      _showError('Failed to load PDFs: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickAndUploadPdf() async {
    try {
      // Pick PDF file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null) return; // User cancelled

      final file = File(result.files.single.path!);
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'unknown';

      // Show loading
      _showLoadingDialog('Uploading PDF...');

      // Upload to bucket
      final pdfUrl = await _pdfService.uploadPdf(
        file,
        userId: userId,
        customName: result.files.single.name,
      );

      if (mounted) Navigator.pop(context); // Close loading dialog

      setState(() => _uploadedPdfUrl = pdfUrl);
      _showSuccess('PDF uploaded successfully!\n\nURL: $pdfUrl');
      _loadPdfs(); // Refresh list
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showError('Failed to upload PDF: $e');
    }
  }

  Future<void> _downloadPdf(String filePath) async {
    try {
      _showLoadingDialog('Downloading PDF...');
      final file = await _pdfService.downloadPdf(filePath);
      if (mounted) Navigator.pop(context);
      _showSuccess('PDF downloaded to: ${file.path}');
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showError('Failed to download PDF: $e');
    }
  }

  Future<void> _deletePdf(String filePath) async {
    try {
      await _pdfService.deletePdf(filePath);
      _showSuccess('PDF deleted successfully');
      _loadPdfs(); // Refresh list
    } catch (e) {
      _showError('Failed to delete PDF: $e');
    }
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Browser'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Upload Section
          Container(
            color: Colors.blue.shade50,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickAndUploadPdf,
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Upload PDF'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                if (_uploadedPdfUrl != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Last Uploaded:'),
                        const SizedBox(height: 4),
                        Text(
                          _uploadedPdfUrl!,
                          style: const TextStyle(
                            fontSize: 12,
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Scaffold.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('URL copied: $_uploadedPdfUrl'),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.copy, size: 16),
                                label: const Text('Copy URL'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // Open PDF in browser or app
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Opening PDF...'),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.open_in_browser, size: 16),
                                label: const Text('View'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // PDFs List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _pdfs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.picture_as_pdf,
                              size: 64,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No PDFs uploaded yet',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _pdfs.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final pdf = _pdfs[index];
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.picture_as_pdf),
                              title: Text(pdf.name),
                              subtitle: Text(
                                'Size: ${(pdf.metadata?.size ?? 0) / 1024 / 1024} MB',
                              ),
                              trailing: PopupMenuButton(
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    onTap: () => _downloadPdf(pdf.name),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.download),
                                        SizedBox(width: 8),
                                        Text('Download'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    onTap: () => _deletePdf(pdf.name),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Delete'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loadPdfs,
        icon: const Icon(Icons.refresh),
        label: const Text('Refresh'),
      ),
    );
  }
}
