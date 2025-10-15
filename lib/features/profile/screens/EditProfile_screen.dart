import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';
import '../services/profile_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;
  final _profileService = ProfileService();
  final _picker = ImagePicker();
  
  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _pseudoController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isLoading = false;
  Profile? _currentProfile;
  String? _avatarUrl;

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
        // Load email from auth
        _emailController.text = user.email ?? '';
        
        // Load profile data
        final profile = await _profileService.getProfile(user.id);
        if (profile != null) {
          _currentProfile = profile;
          _firstNameController.text = profile.firstName ?? '';
          _lastNameController.text = profile.lastName ?? '';
          _pseudoController.text = profile.pseudo ?? '';
          _phoneController.text = profile.phone ?? '';
          _avatarUrl = profile.avatarUrl;
        }
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

  Future<void> _pickAndUploadImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;

    setState(() => _isLoading = true);

    try {
      final file = File(picked.path);
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final ext = p.extension(file.path);
      final filename = '${user.id}_avatar$ext';
      final pathInBucket = 'avatars/$filename';

      // Upload (upsert true so re-upload replaces)
      await _supabase.storage.from('avatars').upload(
        pathInBucket,
        file,
        fileOptions: const FileOptions(upsert: true),
      );

      // Get public URL
      final publicUrl = _supabase.storage.from('avatars').getPublicUrl(pathInBucket);

      // Update profile with new avatar URL
      await _supabase.from('profiles').update({'avatar_url': publicUrl}).eq('id', user.id);

      setState(() {
        _avatarUrl = publicUrl;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avatar uploaded'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
// ...existing code...

Future<void> _updateProfile() async {
  if (!_formKey.currentState!.validate()) return;
  
  setState(() => _isLoading = true);
  
  try {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Update email in auth if changed
    if (_emailController.text.trim() != user.email) {
      await _supabase.auth.updateUser(
        UserAttributes(email: _emailController.text.trim()),
      );
    }

    // Update or create profile
    Profile updatedProfile;
    if (_currentProfile != null) {
      updatedProfile = await _profileService.updateProfile(
        userId: user.id,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        pseudo: _pseudoController.text.trim(),
        phone: _phoneController.text.trim().isNotEmpty 
            ? _phoneController.text.trim() 
            : null,
        avatarUrl: _avatarUrl,
      );
    } else {
      updatedProfile = await _profileService.createProfile(
        userId: user.id,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        pseudo: _pseudoController.text.trim(),
        phone: _phoneController.text.trim().isNotEmpty 
            ? _phoneController.text.trim() 
            : null,
        avatarUrl: _avatarUrl,
      );
    }
    
    if (mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Wait a moment for user to see the success message
      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate to profile screen and remove all previous routes
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/profile', // Make sure this route exists in your app
        (route) => route.isFirst, // Keep only the first route (usually home)
      );
      
      // Alternative: If you want to go back to previous screen instead
      // Navigator.pop(context, updatedProfile);
      
      // Alternative: If you have a specific profile screen widget
      // Navigator.of(context).pushReplacement(
      //   MaterialPageRoute(
      //     builder: (context) => ProfileScreen(profile: updatedProfile),
      //   ),
      // );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
  
  setState(() => _isLoading = false);
}

// ...existing code...

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!value.contains('@')) return 'Enter a valid email';
    return null;
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Avatar with edit icon
                        Center(
                          child: GestureDetector(
                            onTap: _isLoading ? null : _pickAndUploadImage,
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.grey,
                                  backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                                  child: _avatarUrl == null ? const Icon(Icons.person, size: 50, color: Colors.white) : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Form fields
                        TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            labelText: 'First Name *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) => _validateRequired(value, 'First Name'),
                        ),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            labelText: 'Last Name *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) => _validateRequired(value, 'Last Name'),
                        ),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _pseudoController,
                          decoration: const InputDecoration(
                            labelText: 'Username/Pseudo *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.alternate_email),
                          ),
                          validator: (value) => _validateRequired(value, 'Username'),
                        ),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: _validateEmail,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                  
                  // Update button at the bottom
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.save, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Update Profile',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _pseudoController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}