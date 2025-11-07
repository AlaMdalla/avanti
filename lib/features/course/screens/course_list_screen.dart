import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course.dart';
import '../services/course_service.dart';
import 'course_form_screen.dart';
import 'course_view_screen.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final _service = CourseService();
  late Future<List<Course>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.list();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _service.list();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Courses')),
      body: FutureBuilder<List<Course>>(
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
            return const Center(child: Text('No courses yet'));
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final c = items[i];
                return ListTile(
                  leading: c.imageUrl != null
                      ? CircleAvatar(backgroundImage: NetworkImage(c.imageUrl!))
                      : const CircleAvatar(child: Icon(Icons.school)),
                  title: Text(c.title),
                  subtitle: Text(c.description ?? ''),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CourseViewScreen(courseId: c.id)),
                    );
                    _refresh();
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CourseFormScreen(editing: c),
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
          final user = Supabase.instance.client.auth.currentUser;
          if (user == null) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please sign in to create a course')),
              );
            }
            return;
          }
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CourseFormScreen()),
          );
          _refresh();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
