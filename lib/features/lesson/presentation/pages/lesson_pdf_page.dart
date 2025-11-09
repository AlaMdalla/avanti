import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class LessonPdfPage extends StatelessWidget {
  final String pdfUrl;
  const LessonPdfPage({super.key, required this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    final isNetwork = pdfUrl.startsWith('http://') || pdfUrl.startsWith('https://');
    return Scaffold(
      appBar: AppBar(title: const Text('PDF')),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            try {
              if (isNetwork) {
                return SfPdfViewer.network(
                  pdfUrl,
                  canShowScrollHead: true,
                  canShowScrollStatus: true,
                );
              } else {
                final file = File(pdfUrl);
                if (!file.existsSync()) {
                  return Center(
                    child: Text(
                      'Fichier introuvable:\n$pdfUrl',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  );
                }
                return SfPdfViewer.file(
                  file,
                  canShowScrollHead: true,
                  canShowScrollStatus: true,
                );
              }
            } catch (e) {
              return Center(
                child: Text(
                  'Erreur de lecture du PDF:\n$e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
