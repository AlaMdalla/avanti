import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/quiz_models.dart';
import '../services/quiz_service.dart';

class TakeQuizScreen extends StatefulWidget {
  final String quizId;
  final String? quizTitle;
  const TakeQuizScreen({super.key, required this.quizId, this.quizTitle});

  @override
  State<TakeQuizScreen> createState() => _TakeQuizScreenState();
}

class _TakeQuizScreenState extends State<TakeQuizScreen> {
  final _service = QuizService();
  late Future<QuizWithQuestions> _future;
  final Map<String, String> _selected = {};
  Timer? _timer;
  int? _remaining; // seconds
  bool _submitted = false;
  QuizAttempt? _attempt;
  bool _certified = false; // earned certification (score >= 70%)

  @override
  void initState() {
    super.initState();
    _future = _service.getQuizWithQuestions(widget.quizId);
    _future.then((data) {
      if (data.quiz.timeLimitSeconds > 0) {
        setState(() {
          _remaining = data.quiz.timeLimitSeconds;
        });
        _timer = Timer.periodic(const Duration(seconds: 1), (t) {
          if (!mounted) return;
          setState(() {
            _remaining = (_remaining ?? 0) - 1;
            if ((_remaining ?? 0) <= 0) {
              _remaining = 0;
              t.cancel();
              _autoSubmit();
            }
          });
        });
      }
    });
  }

  void _autoSubmit() {
    if (_submitted) return;
    _submit();
  }

  Future<void> _submit() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to submit quiz')),
      );
      return;
    }
    try {
      final attempt = await _service.submitAttempt(
        quizId: widget.quizId,
        userId: user.id,
        selectedOptionIdByQuestionId: _selected,
      );
      // Try to award certification if eligible
      bool certified = false;
      try {
        certified = await _service.awardCertificationIfEligible(attempt: attempt);
      } catch (_) {
        // ignore persistence errors; UI will still show based on local percent
      }
      if (!mounted) return;
      setState(() {
        _attempt = attempt;
        _submitted = true;
        _timer?.cancel();
        final percentValue = attempt.correctCount / (attempt.total == 0 ? 1 : attempt.total) * 100;
        _certified = certified || percentValue >= 70.0;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quizTitle ?? 'Quiz'),
        actions: [
          if (_remaining != null && !_submitted)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Center(
                child: Text(
                  _formatRemaining(_remaining!),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      body: FutureBuilder<QuizWithQuestions>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
            final data = snapshot.data;
          if (data == null) return const Center(child: Text('Not found'));

          if (_submitted && _attempt != null) {
            final percent = (_attempt!.correctCount / (_attempt!.total == 0 ? 1 : _attempt!.total) * 100).toStringAsFixed(1);
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, size: 72, color: Colors.green),
                  const SizedBox(height: 24),
                  Text('Score: ${_attempt!.correctCount} / ${_attempt!.total} ($percent%)', style: Theme.of(context).textTheme.headlineSmall),
                  if (_certified) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.workspace_premium, color: Colors.amber, size: 32),
                        SizedBox(width: 8),
                        Text('Certification earned!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('You scored 70% or higher.'),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back'),
                  ),
                ],
              ),
            );
          }

          if (data.questions.isEmpty) {
            return const Center(child: Text('No questions for this quiz yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.questions.length + 1,
            itemBuilder: (context, index) {
              if (index == data.questions.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: FilledButton.icon(
                    onPressed: _selected.length == data.questions.length ? _submit : null,
                    icon: const Icon(Icons.send),
                    label: const Text('Submit'),
                  ),
                );
              }
              final q = data.questions[index];
              final opts = data.optionsByQuestionId[q.id] ?? [];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Q${index + 1}. ${q.text}', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      for (final o in opts)
                        RadioListTile<String>(
                          value: o.id,
                          groupValue: _selected[q.id],
                          onChanged: _submitted
                              ? null
                              : (val) {
                                  setState(() {
                                    _selected[q.id] = val!;
                                  });
                                },
                          title: Text(o.text),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatRemaining(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
