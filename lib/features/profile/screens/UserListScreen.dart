import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../services/ProfileService.dart';
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
      // Sort by pseudo (nulls last)
      _users.sort((a, b) => (a['pseudo'] ?? '').compareTo(b['pseudo'] ?? ''));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users', style: AppTextStyles.h4),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Container(
        color: AppColors.background,
        child: ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: _users.length,
          itemBuilder: (context, index) {
            final user = _users[index];
            final userId = user['user_id'];
            final pseudo = user['pseudo'];
            final email = user['email'];
            final avatarUrl = user['avatar_url'];
            final displayName = pseudo ?? email ?? 'User $userId';
            if (userId == _currentUserId) return SizedBox.shrink();
            return Card(
              color: AppColors.surface,
              elevation: 0,
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                side: BorderSide(color: AppColors.surfaceVariant, width: 1),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(AppSpacing.md),
                leading: CircleAvatar(
                  backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl == null ? Text(displayName[0].toUpperCase(), style: AppTextStyles.caption.copyWith(color: AppColors.textOnPrimary)) : null,
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  radius: 24,
                ),
                title: Text(displayName, style: AppTextStyles.bodyMedium),
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
              ),
            );
          },
        ),
      ),
    );
  }
}