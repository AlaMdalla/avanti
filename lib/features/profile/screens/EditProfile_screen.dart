import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';
import '../services/profile_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import '../../../core/utils/validators.dart';

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
        _emailController.text = user.email ?? '';
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
      _showErrorSnack('Error loading profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
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

      await _supabase.storage.from('avatars').upload(
            pathInBucket,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = _supabase.storage.from('avatars').getPublicUrl(pathInBucket);
      await _supabase.from('profiles').update({'avatar_url': publicUrl}).eq('id', user.id);

      setState(() => _avatarUrl = publicUrl);
      _showSuccessSnack('Avatar uploaded successfully!');
    } catch (e) {
      _showErrorSnack('Upload failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      if (_emailController.text.trim() != user.email) {
        await _supabase.auth.updateUser(UserAttributes(email: _emailController.text.trim()));
      }

      if (_currentProfile != null) {
        await _profileService.updateProfile(
          userId: user.id,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          pseudo: _pseudoController.text.trim(),
          phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
          avatarUrl: _avatarUrl,
        );
      } else {
        await _profileService.createProfile(
          userId: user.id,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          pseudo: _pseudoController.text.trim(),
          phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
          avatarUrl: _avatarUrl,
        );
      }

      _showSuccessSnack('Profile updated successfully!');
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) Navigator.pushReplacementNamed(context, '/profile');
    } catch (e) {
      _showErrorSnack('Error updating profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }


  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4F46E5);
    const primaryLight = Color(0xFF6366F1);
    const textPrimary = Color(0xFF1F2937);
    const textSecondary = Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: primaryColor,
        centerTitle: true,
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary),
        ),
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: primaryColor))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _pickAndUploadImage,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [primaryColor, primaryLight],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.white,
                                  backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                                  child: _avatarUrl == null
                                      ? const Icon(Icons.person, size: 60, color: textSecondary)
                                      : null,
                                ),
                              ),
                              Positioned(
                                bottom: 6,
                                right: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        _buildTextField(
                          controller: _firstNameController,
                          label: 'First Name *',
                          icon: Icons.person_outline,
                          validator: (v) => Validators.combine(v, [
                            Validators.required,
                            (val) => Validators.alphabetic(val, fieldName: 'First Name'),
                            (val) => Validators.maxLength(val, 50, fieldName: 'First Name'),
                          ]),
                        ),
                        _buildTextField(
                          controller: _lastNameController,
                          label: 'Last Name *',
                          icon: Icons.person_outline,
                          validator: (v) => Validators.combine(v, [
                            Validators.required,
                            (val) => Validators.alphabetic(val, fieldName: 'Last Name'),
                            (val) => Validators.maxLength(val, 50, fieldName: 'Last Name'),
                          ]),
                        ),
                        _buildTextField(
                          controller: _pseudoController,
                          label: 'Username / Pseudo *',
                          icon: Icons.alternate_email,
                          validator: (v) => Validators.combine(v, [
                            Validators.required,
                            (val) => Validators.minLength(val, 3, fieldName: 'Username'),
                            (val) => Validators.maxLength(val, 30, fieldName: 'Username'),
                          ]),
                        ),
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email *',
                          icon: Icons.email_outlined,
                          validator: Validators.email,
                        ),
                        _buildTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          icon: Icons.phone_outlined,
                          validator: (v) => Validators.phone(v, required: false),
                        ),

                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _updateProfile,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Ink(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [primaryColor, primaryLight],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                child: const Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    const textPrimary = Color(0xFF1F2937);
    const textSecondary = Color(0xFF6B7280);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: validator,
        style: const TextStyle(color: textPrimary, fontSize: 16),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: textSecondary),
          labelText: label,
          labelStyle: const TextStyle(color: textSecondary),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
          ),
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
