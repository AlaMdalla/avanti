import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class CertificateScreen extends StatelessWidget {
  final int score;
  final int total;

  const CertificateScreen({
    super.key,
    required this.score,
    required this.total,
  });

  // 🔹 Génération du certificat PDF
  Future<void> _generateCertificatePDF(BuildContext context) async {
    final pdf = pw.Document();
    final percentage = (score / total) * 100;

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(32),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 3),
              ),
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text('CERTIFICAT DE RÉUSSITE 🎓',
                      style: pw.TextStyle(
                        fontSize: 26,
                        fontWeight: pw.FontWeight.bold,
                      )),
                  pw.SizedBox(height: 30),
                  pw.Text('Ce certificat est décerné à',
                      style: const pw.TextStyle(fontSize: 16)),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Étudiant(e) Avanti',
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'pour avoir complété le quiz avec succès avec un score de ${percentage.toStringAsFixed(1)} %',
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(fontSize: 16),
                  ),
                  pw.SizedBox(height: 40),
                  pw.Text(
                    'Date : ${DateTime.now().toLocal().toString().split(" ")[0]}',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                  pw.SizedBox(height: 30),
                  pw.Text('________________________'),
                  pw.Text('Avanti Learning Platform',
                      style: const pw.TextStyle(fontSize: 14)),
                ],
              ),
            ),
          );
        },
      ),
    );

    // 📂 Enregistrer le PDF dans un dossier temporaire
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/certificate.pdf");
    await file.writeAsBytes(await pdf.save());

    // 📤 Partager / télécharger le PDF
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'certificate.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool passed = (score / total) >= 0.7;
    final percentage = (score / total) * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Certificat de réussite"),
        backgroundColor: Colors.blueAccent,
        elevation: 2,
      ),
      body: Center(
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.blueAccent, width: 3),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 4,
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "🎓 CERTIFICAT DE RÉUSSITE 🎓",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),
              Icon(
                passed ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                color: passed ? Colors.amber : Colors.redAccent,
                size: 80,
              ),
              const SizedBox(height: 20),
              Text(
                passed
                    ? "Félicitations 🎉 Vous avez réussi le quiz !"
                    : "Dommage 😢 Vous pouvez réessayer.",
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "Score : $score / $total (${percentage.toStringAsFixed(1)}%)",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 40),
              if (passed)
                ElevatedButton.icon(
                  onPressed: () async {
                    await _generateCertificatePDF(context);
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("Télécharger le certificat"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.home),
                label: const Text("Retour à l'accueil"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
