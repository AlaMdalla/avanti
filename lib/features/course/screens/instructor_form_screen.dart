import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/instructor.dart';
import '../services/instructor_service.dart';

class InstructorFormScreen extends StatefulWidget {
  final Instructor? editing;
  const InstructorFormScreen({super.key, this.editing});

  @override
  State<InstructorFormScreen> createState() => _InstructorFormScreenState();
}

class _InstructorFormScreenState extends State<InstructorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _specializationCtrl = TextEditingController();
  final _service = InstructorService();
  bool _saving = false;
  final _picker = ImagePicker();
  File? _pickedImage;
  String? _uploadedUrl;

  @override
  void initState() {
    super.initState();
    if (widget.editing != null) {
      _nameCtrl.text = widget.editing!.name;
      _emailCtrl.text = widget.editing!.email ?? '';
      _bioCtrl.text = widget.editing!.bio ?? '';
      _specializationCtrl.text = widget.editing!.specialization ?? '';
      _uploadedUrl = widget.editing!.avatarUrl;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _bioCtrl.dispose();
    _specializationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final result = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (result != null) {
        setState(() => _pickedImage = File(result.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      // Upload avatar if picked
      String? finalAvatarUrl = _uploadedUrl;
      if (_pickedImage != null) {
        final user = Supabase.instance.client.auth.currentUser;
        if (user == null) throw Exception('Not authenticated');
        finalAvatarUrl = await _service.uploadAvatar(
          _pickedImage!,
          instructorId: widget.editing?.id ?? user.id,
        );
      }

      final input = InstructorInput(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
        specialization: _specializationCtrl.text.trim().isEmpty
            ? null
            : _specializationCtrl.text.trim(),
        avatarUrl: finalAvatarUrl,
      );

      if (widget.editing == null) {
        await _service.create(input);
      } else {
        await _service.update(widget.editing!.id, input);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.editing == null
                ? 'Instructor created successfully'
                : 'Instructor updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editing == null ? 'Add Instructor' : 'Edit Instructor'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Section
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _pickedImage != null
                          ? FileImage(_pickedImage!)
                          : _uploadedUrl != null
                              ? NetworkImage(_uploadedUrl!)
                              : null,
                      child: (_pickedImage == null && _uploadedUrl == null)
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _saving ? null : _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Change Avatar'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Name Field
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  hintText: 'Enter instructor name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email Field
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'instructor@example.com',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Specialization Field
              TextFormField(
                controller: _specializationCtrl,
                decoration: const InputDecoration(
                  labelText: 'Specialization',
                  hintText: 'e.g., Flutter Development, Web Design',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.star),
                ),
              ),
              const SizedBox(height: 16),

              // Bio Field
              TextFormField(
                controller: _bioCtrl,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  hintText: 'Write a brief bio about the instructor',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 4,
                minLines: 3,
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          widget.editing == null
                              ? 'Create Instructor'
                              : 'Update Instructor',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Delete Button (only for editing)
              if (widget.editing != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : () => _showDeleteConfirmation(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Delete Instructor'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Instructor'),
        content: Text(
          'Are you sure you want to delete ${widget.editing!.name}? This action cannot be undone.',
        ),
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

    setState(() => _saving = true);
    try {
      await _service.delete(widget.editing!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Instructor deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
