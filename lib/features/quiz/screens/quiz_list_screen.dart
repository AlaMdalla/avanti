import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../course/models/course.dart';
import '../models/quiz_models.dart';
import '../services/quiz_service.dart';
import 'take_quiz_screen.dart';
import 'quiz_form_screen.dart';
import 'questions_editor_screen.dart';

class QuizListScreen extends StatefulWidget {
  final String courseId;
  final String? courseTitle;
  const QuizListScreen({super.key, required this.courseId, this.courseTitle});

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  final _service = QuizService();
  late Future<List<Quiz>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.listByCourse(widget.courseId);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _service.listByCourse(widget.courseId);
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.courseTitle ?? 'Quizzes')),
      body: FutureBuilder<List<Quiz>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('No quizzes yet'));
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final q = items[i];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.quiz_outlined)),
                  title: Text(q.title),
                  subtitle: Text(q.description ?? ''),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TakeQuizScreen(quizId: q.id, quizTitle: q.title),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuestionsEditorScreen(quizId: q.id, quizTitle: 'Edit: ${q.title}'),
                        ),
                      );
                      _refresh();
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QuizFormScreen(courseId: widget.courseId),
            ),
          );
          if (created == true) {
            _refresh();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
