import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../profile/services/profile_service.dart';
import '../../profile/models/profile.dart';
import '../models/course.dart';
import '../services/course_service.dart';
import 'course_form_screen.dart';
import 'pdf_viewer_screen.dart';
import '../../quiz/screens/quiz_list_screen.dart';

class CourseViewScreen extends StatefulWidget {
  final String courseId;
  const CourseViewScreen({super.key, required this.courseId});

  @override
  State<CourseViewScreen> createState() => _CourseViewScreenState();
}

class _CourseViewScreenState extends State<CourseViewScreen> {
  final _service = CourseService();
  late Future<Course> _future;
  final _profileService = ProfileService();
  Profile? _profile;

  @override
  void initState() {
    super.initState();
    _future = _service.getById(widget.courseId);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final p = await _profileService.getProfile(user.id);
    if (!mounted) return;
    setState(() => _profile = p);
  }

  Future<void> _reload() async {
    setState(() {
      _future = _service.getById(widget.courseId);
    });
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete course'),
        content: const Text('Are you sure you want to delete this course?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _service.delete(widget.courseId);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _openPdf(String pdfUrl) async {
    try {
      // Open PDF in app using PDF viewer
      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PdfViewerScreen(
              pdfUrl: pdfUrl,
              title: 'Course Material',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _profile?.role == ProfileRole.admin;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reload,
          ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: FutureBuilder<Course>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final course = snapshot.data;
          if (course == null) return const Center(child: Text('Not found'));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (course.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(course.imageUrl!, height: 180, fit: BoxFit.cover),
                ),
              const SizedBox(height: 16),
              Text(course.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(course.description ?? 'No description'),
              const SizedBox(height: 24),
              // PDF Section
              if (course.pdfUrl != null)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.picture_as_pdf, color: Colors.red.shade700, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Course PDF Content',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Click below to view the course material',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => _openPdf(course.pdfUrl!),
                              icon: const Icon(Icons.open_in_browser),
                              label: const Text('View PDF'),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red.shade700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () {
                              // Copy URL to clipboard
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('PDF URL copied to clipboard')),
                              );
                            },
                            icon: const Icon(Icons.download),
                            label: const Text('Download'),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.picture_as_pdf, color: Colors.grey.shade400, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No PDF content available for this course',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              if (isAdmin)
                FilledButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CourseFormScreen(editing: course),
                      ),
                    );
                    _reload();
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuizListScreen(courseId: course.id, courseTitle: 'Quizzes: ${course.title}'),
                    ),
                  );
                },
                icon: const Icon(Icons.quiz_outlined),
                label: const Text('Quizzes'),
              ),
            ],
          );
        },
      ),
    );
  }
}
