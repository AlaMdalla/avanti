import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../course/models/course.dart';
import '../../course/screens/course_form_screen.dart';
import '../../course/services/course_service.dart';
import '../../profile/services/profile_service.dart';
import '../../profile/models/profile.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _courseService = CourseService();
  final _profileService = ProfileService();
  late Future<List<Course>> _futureCourses;
  Profile? _profile;

  @override
  void initState() {
    super.initState();
    _futureCourses = _courseService.list();
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
      _futureCourses = _courseService.list();
    });
    await _futureCourses;
  }

  bool get _isAdmin => _profile?.role == ProfileRole.admin;

  @override
  Widget build(BuildContext context) {
    if (_profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!_isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin')),
        body: const Center(child: Text('Access denied (admins only)')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: FutureBuilder<List<Course>>(
        future: _futureCourses,
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
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const CourseFormScreen()));
          _refresh();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
