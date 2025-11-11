import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerScreen({
    Key? key,
    required this.pdfUrl,
    required this.title,
  }) : super(key: key);

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  bool _isLoading = false;

  Future<void> _openPdf() async {
    try {
      setState(() => _isLoading = true);
      
      if (await canLaunchUrl(Uri.parse(widget.pdfUrl))) {
        await launchUrl(
          Uri.parse(widget.pdfUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open PDF')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
      ),
      body: Center(
        child: _isLoading
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Opening PDF...'),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.picture_as_pdf,
                    size: 80,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'PDF: ${widget.title}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Click "Open PDF" to view in your default PDF reader',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _openPdf,
                    icon: const Icon(Icons.open_in_browser),
                    label: const Text('Open PDF'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                  ),
                ],
              ),
      ),
    );
  }
}
