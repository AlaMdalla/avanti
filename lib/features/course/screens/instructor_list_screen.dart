import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../profile/services/profile_service.dart';
import '../../profile/models/profile.dart';
import '../models/instructor.dart';
import '../services/instructor_service.dart';
import 'instructor_form_screen.dart';
import 'instructor_view_screen.dart';

class InstructorListScreen extends StatefulWidget {
  const InstructorListScreen({super.key});

  @override
  State<InstructorListScreen> createState() => _InstructorListScreenState();
}

class _InstructorListScreenState extends State<InstructorListScreen> {
  final _service = InstructorService();
  late Future<List<Instructor>> _future;
  final _profileService = ProfileService();
  Profile? _profile;
  final _searchCtrl = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _future = _service.list();
    _loadProfile();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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
      _isSearching = false;
      _searchCtrl.clear();
      _future = _service.list();
    });
    await _future;
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      _refresh();
      return;
    }
    setState(() => _isSearching = true);
    setState(() => _future = _service.getByName(query));
  }

  Future<void> _deleteInstructor(Instructor instructor) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Instructor'),
        content: Text('Are you sure you want to delete ${instructor.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _service.delete(instructor.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Instructor deleted successfully')),
        );
        _refresh();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _duplicateInstructor(Instructor instructor) async {
    try {
      final newInstructor = instructor.copyWith(
        id: '',
        createdAt: null,
        updatedAt: null,
      );
      
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InstructorFormScreen(editing: newInstructor),
          ),
        ).then((_) => _refresh());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _bulkDeleteInstructors(List<Instructor> instructors) async {
    if (instructors.isEmpty) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Multiple Instructors'),
        content: Text('Are you sure you want to delete ${instructors.length} instructor(s)? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      for (final instructor in instructors) {
        await _service.delete(instructor.id);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${instructors.length} instructor(s) deleted successfully')),
        );
        _refresh();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _profile?.role == ProfileRole.admin;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(
                  hintText: 'Search instructors...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: _search,
              )
            : const Text('Instructors'),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => setState(() => _isSearching = true),
            ),
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() {
                _isSearching = false;
                _searchCtrl.clear();
                _refresh();
              }),
            ),
        ],
      ),
      body: FutureBuilder<List<Instructor>>(
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    _isSearching ? 'No instructors found' : 'No instructors yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final instructor = items[index];
                return _InstructorCard(
                  instructor: instructor,
                  isAdmin: isAdmin,
                  onView: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InstructorViewScreen(instructorId: instructor.id),
                    ),
                  ).then((_) => _refresh()),
                  onEdit: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InstructorFormScreen(editing: instructor),
                    ),
                  ).then((_) => _refresh()),
                  onDuplicate: () => _duplicateInstructor(instructor),
                  onDelete: () => _deleteInstructor(instructor),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InstructorFormScreen()),
              ).then((_) => _refresh()),
              tooltip: 'Add Instructor',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

/// Card widget to display instructor information
class _InstructorCard extends StatelessWidget {
  final Instructor instructor;
  final bool isAdmin;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onDuplicate;
  final VoidCallback? onBulkDelete;

  const _InstructorCard({
    required this.instructor,
    required this.isAdmin,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    this.onDuplicate,
    this.onBulkDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: instructor.avatarUrl != null
              ? NetworkImage(instructor.avatarUrl!)
              : null,
          child: instructor.avatarUrl == null
              ? const Icon(Icons.person)
              : null,
        ),
        title: Text(
          instructor.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (instructor.specialization != null) ...[
              const SizedBox(height: 4),
              Text(
                instructor.specialization!,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            if (instructor.email != null) ...[
              const SizedBox(height: 4),
              Text(
                instructor.email!,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ],
        ),
        trailing: isAdmin
            ? PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'view') onView();
                  if (value == 'edit') onEdit();
                  if (value == 'duplicate') onDuplicate?.call();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(value: 'view', child: Text('View')),
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
              )
            : const Icon(Icons.chevron_right),
        onTap: onView,
      ),
    );
  }
}
