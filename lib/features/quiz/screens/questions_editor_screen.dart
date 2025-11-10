import 'package:flutter/material.dart';
import '../models/quiz_models.dart';
import '../services/quiz_service.dart';

class QuestionsEditorScreen extends StatefulWidget {
  final String quizId;
  final String? quizTitle;
  const QuestionsEditorScreen({super.key, required this.quizId, this.quizTitle});

  @override
  State<QuestionsEditorScreen> createState() => _QuestionsEditorScreenState();
}

class _QuestionsEditorScreenState extends State<QuestionsEditorScreen> {
  final _service = QuizService();
  late Future<QuizWithQuestions> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getQuizWithQuestions(widget.quizId);
  }

  Future<void> _reload() async {
    setState(() {
      _future = _service.getQuizWithQuestions(widget.quizId);
    });
  }

  Future<void> _addQuestion() async {
    String text = '';
    final formKey = GlobalKey<FormState>();
    final optionCtrls = <TextEditingController>[];
    final correctIndex = ValueNotifier<int?>(null);
    bool submitting = false;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('New Question'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Question text'),
                      onChanged: (v) => text = v,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Options'),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setStateDialog(() {
                              optionCtrls.add(TextEditingController());
                            });
                          },
                        ),
                      ],
                    ),
                    ValueListenableBuilder<int?>(
                      valueListenable: correctIndex,
                      builder: (context, idx, _) {
                        return Column(
                          children: [
                            for (int i = 0; i < optionCtrls.length; i++)
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Radio<int>(
                                  value: i,
                                  groupValue: idx,
                                  onChanged: (val) => correctIndex.value = val,
                                ),
                                title: TextField(
                                  controller: optionCtrls[i],
                                  decoration: InputDecoration(labelText: 'Option ${i + 1}'),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    setStateDialog(() {
                                      final removedIdx = i;
                                      optionCtrls.removeAt(i);
                                      if (correctIndex.value == removedIdx) {
                                        correctIndex.value = null;
                                      } else if (correctIndex.value != null && removedIdx < correctIndex.value!) {
                                        correctIndex.value = correctIndex.value! - 1;
                                      }
                                    });
                                  },
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: submitting ? null : () => Navigator.pop(context), child: const Text('Cancel')),
              FilledButton(
                onPressed: submitting
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        if (optionCtrls.length < 2) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Need at least 2 options')));
                          return;
                        }
                        if (correctIndex.value == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select correct option')));
                          return;
                        }
                        setStateDialog(() => submitting = true);
                        try {
                          final q = await _service.createQuestion(quizId: widget.quizId, text: text, order: DateTime.now().millisecondsSinceEpoch);
                          await _service.createOptionsBulk(
                            questionId: q.id,
                            options: [
                              for (int i = 0; i < optionCtrls.length; i++)
                                {
                                  'text': optionCtrls[i].text.trim(),
                                  'is_correct': i == correctIndex.value,
                                }
                            ],
                          );
                          if (mounted) Navigator.pop(context, true);
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                          }
                        } finally {
                          setStateDialog(() => submitting = false);
                        }
                      },
                child: Text(submitting ? 'Saving...' : 'Save'),
              ),
            ],
          );
        });
      },
    );
    _reload();
  }

  Future<void> _deleteQuestion(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete question'),
        content: const Text('This will remove the question and its options.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    await _service.deleteQuestion(id);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.quizTitle ?? 'Questions')),
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
          final questions = data.questions;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: questions.length + 1,
            itemBuilder: (context, index) {
              if (index == questions.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: FilledButton.icon(
                    onPressed: _addQuestion,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Question'),
                  ),
                );
              }
              final q = questions[index];
              final opts = data.optionsByQuestionId[q.id] ?? [];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(q.text, style: Theme.of(context).textTheme.titleMedium)),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _deleteQuestion(q.id),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      for (final o in opts)
                        Row(
                          children: [
                            Icon(o.isCorrect ? Icons.check_circle : Icons.circle_outlined, color: o.isCorrect ? Colors.green : null, size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(o.text)),
                          ],
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
}
