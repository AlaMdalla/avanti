import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../profile/services/profile_service.dart';
import '../../profile/models/profile.dart';
import '../models/instructor.dart';
import '../models/course.dart';
import '../services/instructor_service.dart';
import '../services/course_service.dart';
import 'instructor_form_screen.dart';
import 'course_view_screen.dart';

class InstructorViewScreen extends StatefulWidget {
  final String instructorId;
  const InstructorViewScreen({super.key, required this.instructorId});

  @override
  State<InstructorViewScreen> createState() => _InstructorViewScreenState();
}

class _InstructorViewScreenState extends State<InstructorViewScreen> {
  final _instructorService = InstructorService();
  final _courseService = CourseService();
  final _profileService = ProfileService();
  late Future<Instructor> _instructorFuture;
  late Future<List<Course>> _coursesFuture;
  Profile? _profile;

  @override
  void initState() {
    super.initState();
    _instructorFuture = _instructorService.getById(widget.instructorId);
    _coursesFuture = _courseService.list().then(
      (courses) => courses
          .where((course) => course.instructorId == widget.instructorId)
          .toList(),
    );
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final p = await _profileService.getProfile(user.id);
    if (!mounted) return;
    setState(() => _profile = p);
  }

  Future<void> _refresh() async {
    setState(() {
      _instructorFuture = _instructorService.getById(widget.instructorId);
      _coursesFuture = _courseService.list().then(
        (courses) => courses
            .where((course) => course.instructorId == widget.instructorId)
            .toList(),
      );
    });
    await _instructorFuture;
    await _coursesFuture;
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _profile?.role == ProfileRole.admin;

    return FutureBuilder<Instructor>(
      future: _instructorFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Instructor')),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final instructor = snapshot.data;
        if (instructor == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Instructor')),
            body: const Center(child: Text('Instructor not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Instructor'),
            actions: [
              if (isAdmin)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InstructorFormScreen(editing: instructor),
                    ),
                  ).then((_) => _refresh()),
                ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header Section
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: instructor.avatarUrl != null
                            ? NetworkImage(instructor.avatarUrl!)
                            : null,
                        child: instructor.avatarUrl == null
                            ? const Icon(Icons.person, size: 60)
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        instructor.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      if (instructor.specialization != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text(
                            instructor.specialization!,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Info Section
                if (instructor.email != null || instructor.bio != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (instructor.email != null) ...[
                            Row(
                              children: [
                                const Icon(Icons.email, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(instructor.email!),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (instructor.bio != null) ...[
                            const Text(
                              'About',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              instructor.bio!,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),

                // Courses Section
                Text(
                  'Courses',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                FutureBuilder<List<Course>>(
                  future: _coursesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    final courses = snapshot.data ?? [];
                    if (courses.isEmpty) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.school_outlined,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No courses yet',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: courses
                          .map((course) => _CourseCard(course: course))
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Card widget to display course information
class _CourseCard extends StatelessWidget {
  final Course course;

  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: course.imageUrl != null
            ? Image.network(
                course.imageUrl!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
            : Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.school),
              ),
        title: Text(
          course.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (course.description != null) ...[
              const SizedBox(height: 4),
              Text(
                course.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (course.pdfUrl != null)
              Tooltip(
                message: 'Has PDF',
                child: Icon(Icons.picture_as_pdf, color: Colors.red[400]),
              ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CourseViewScreen(courseId: course.id),
          ),
        ),
      ),
    );
  }
}
