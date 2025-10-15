import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';
import '../services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;
  final _profileService = ProfileService();
  
  bool _isLoading = false;
  Profile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        _profile = await _profileService.getProfile(user.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.pushNamed(context, '/edit-profile'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profile == null
              ? const Center(child: Text('No profile found'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Avatar display using avatarUrl from Profile model
                      Center(
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey,
                          backgroundImage: _profile!.avatarUrl != null
                              ? NetworkImage(_profile!.avatarUrl!)
                              : null,
                          child: _profile!.avatarUrl == null
                              ? const Icon(Icons.person, size: 60, color: Colors.white)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Profile details
                      Text(
                        _profile!.displayName,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Text('Email: ${_supabase.auth.currentUser?.email ?? 'N/A'}'),
                      const SizedBox(height: 8),
                      Text('Pseudo: ${_profile!.pseudo ?? 'N/A'}'),
                      const SizedBox(height: 8),
                      Text('Phone: ${_profile!.phone ?? 'N/A'}'),
                      const SizedBox(height: 8),
                      Text('Member since: ${_profile!.createdAt.toLocal().toString().split(' ')[0]}'),
                    ],
                  ),
                ),
    );
  }
}