import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../profile/services/ProfileService.dart';
import '../../messages/screens/chat_screen.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final ProfileService _profileService = ProfileService();
  List<Map<String, dynamic>> _users = [];
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = Supabase.instance.client.auth.currentUser?.id;
    _loadUsers();
  }

  void _loadUsers() async {
    final profiles = await _profileService.getAllProfiles();
    setState(() {
      _users = profiles.map((profile) => profile.toJson()).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Users')),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          final userId = user['user_id'];
          final name = '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();
          if (userId == _currentUserId) return SizedBox.shrink();  // Skip current user
          return ListTile(
            title: Text(name.isNotEmpty ? name : 'User $userId'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    currentUserId: _currentUserId!,
                    otherUserId: userId,
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