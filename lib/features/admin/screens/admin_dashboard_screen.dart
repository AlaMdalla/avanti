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

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  final _courseService = CourseService();
  final _profileService = ProfileService();
  late Future<List<Course>> _futureCourses;
  late Future<List<Profile>> _futureProfiles;
  Profile? _profile;
  late TabController _tabController;
  bool _updatingRole = false;

  @override
  void initState() {
    super.initState();
  _futureCourses = _courseService.list();
  _futureProfiles = _profileService.getAllProfiles();
  _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final p = await _profileService.getProfile(user.id);
    if (!mounted) return;
    setState(() => _profile = p);
  }

  Future<void> _refreshCourses() async {
    setState(() {
      _futureCourses = _courseService.list();
    });
    await _futureCourses;
  }

  Future<void> _refreshProfiles() async {
    setState(() {
      _futureProfiles = _profileService.getAllProfiles();
    });
    await _futureProfiles;
  }

  Future<void> _updateRole(Profile profile, ProfileRole newRole) async {
    if (_updatingRole) return;
    setState(() => _updatingRole = true);
    try {
      await _profileService.updateProfile(userId: profile.userId, role: newRole.name);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Role updated to ${newRole.name}')),);
      _refreshProfiles();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update role: $e')),
      );
    } finally {
      if (mounted) setState(() => _updatingRole = false);
    }
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
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Courses'),
            Tab(text: 'Profiles'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Courses tab
          FutureBuilder<List<Course>>(
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
                onRefresh: _refreshCourses,
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
                          _refreshCourses();
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
          // Profiles tab
          FutureBuilder<List<Profile>>(
            future: _futureProfiles,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final profiles = snapshot.data ?? [];
              if (profiles.isEmpty) {
                return const Center(child: Text('No profiles')); 
              }
              return RefreshIndicator(
                onRefresh: _refreshProfiles,
                child: ListView.separated(
                  itemCount: profiles.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final p = profiles[i];
                    final isSelf = _profile?.userId == p.userId;
                    return ListTile(
                      leading: p.avatarUrl != null
                          ? CircleAvatar(backgroundImage: NetworkImage(p.avatarUrl!))
                          : const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(p.displayName),
                      subtitle: Text(
                        p.role.name + (isSelf ? ' (you)' : ''),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      trailing: AbsorbPointer(
                        absorbing: isSelf || _updatingRole,
                        child: Opacity(
                          opacity: (isSelf || _updatingRole) ? 0.6 : 1,
                          child: DropdownButton<ProfileRole>(
                            value: p.role,
                            onChanged: (val) {
                              if (val != null && val != p.role) {
                                _updateRole(p, val);
                              }
                            },
                            items: ProfileRole.values
                                .map((r) => DropdownMenuItem(
                                      value: r,
                                      child: Text(r.name),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const CourseFormScreen()));
                _refreshCourses();
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
