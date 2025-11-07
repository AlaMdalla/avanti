import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:avanti_mobile/features/reclamation/screens/add_reclamation_from_quiz.dart';


class QuizScreen extends StatefulWidget {
  final String courseId;
  final String courseTitle;

  const QuizScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Map<String, dynamic>> questions = [];
  int currentIndex = 0;
  int score = 0;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    final response = await Supabase.instance.client
        .from('quizzes')
        .select()
        .eq('course_id', widget.courseId);

    setState(() {
      questions = List<Map<String, dynamic>>.from(response);
    });
  }

  void _checkAnswer(String selected, Map<String, dynamic> question) {
    final correctLetter = question['correct_option'];
    final correctText = {
      'A': question['option_a'],
      'B': question['option_b'],
      'C': question['option_c'],
      'D': question['option_d'],
    }[correctLetter];

    if (selected == correctText) score++;

    if (currentIndex < questions.length - 1) {
      setState(() => currentIndex++);
    } else {
      _showResult();
    }
  }

  Future<void> _assignCertificate() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    await Supabase.instance.client.from('certificates').insert({
      'user_id': user.id,
      'course_id': widget.courseId,
      'score': score,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _generateCertificatePDF(double percentage) async {
    final pdf = pw.Document();
    final user = Supabase.instance.client.auth.currentUser;
    final userName = user?.email?.split('@').first ?? 'Étudiant';

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
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
                        fontSize: 26, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 30),
                pw.Text('Ce certificat est décerné à',
                    style: const pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 10),
                pw.Text(userName,
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Text(
                    'pour avoir complété le cours "${widget.courseTitle}" avec un score de ${percentage.toStringAsFixed(1)} %',
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 40),
                pw.Text(
                    'Date : ${DateTime.now().toLocal().toString().split(" ")[0]}'),
                pw.SizedBox(height: 30),
                pw.Text('________________________'),
                pw.Text('Avanti Learning Platform',
                    style: const pw.TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'certificate_${widget.courseTitle}.pdf',
    );
  }

  void _showResult() async {
    final percentage = (score / questions.length) * 100;

    if (percentage >= 70) await _assignCertificate();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Quiz terminé 🎉'),
        content: Text(
          percentage >= 70
              ? 'Félicitations 🎓 ! Tu as réussi avec ${percentage.toStringAsFixed(1)} %.\nUn certificat t’a été attribué !'
              : 'Ton score : $score / ${questions.length}\n(${percentage.toStringAsFixed(1)} %)\nEssaie encore pour obtenir ton certificat !',
        ),
        actions: [
          if (percentage >= 70)
            TextButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Télécharger le certificat'),
              onPressed: () async {
                Navigator.pop(context);
                await _generateCertificatePDF(percentage);
              },
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Retour'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Quiz - ${widget.courseTitle}')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final question = questions[currentIndex];
    final options = [
      question['option_a'],
      question['option_b'],
      question['option_c'],
      question['option_d'],
    ];

    return Scaffold(
      appBar: AppBar(title: Text(widget.courseTitle)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${currentIndex + 1}/${questions.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              question['question'] ?? '',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ...options.map((opt) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: ElevatedButton(
                  onPressed: () => _checkAnswer(opt, question),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: Text(opt ?? ''),
                ),
              );
            }),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.report_problem),
                label: const Text("Faire une réclamation"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddReclamationFromQuiz(
                        courseId: widget.courseId,
                        courseTitle: widget.courseTitle,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
