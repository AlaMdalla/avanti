import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/course.dart';
import '../services/course_service.dart';
import 'course_list_screen.dart';

class CourseFormScreen extends StatefulWidget {
  final Course? editing;

  const CourseFormScreen({super.key, this.editing});

  @override
  State<CourseFormScreen> createState() => _CourseFormScreenState();
}

class _CourseFormScreenState extends State<CourseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  final _service = CourseService();
  bool _saving = false;
  final _picker = ImagePicker();
  File? _pickedImage;
  String? _uploadedUrl;

  @override
  void initState() {
    super.initState();
    if (widget.editing != null) {
      _titleCtrl.text = widget.editing!.title;
      _descCtrl.text = widget.editing!.description ?? '';
      _uploadedUrl = widget.editing!.imageUrl;
      _imageCtrl.text = widget.editing!.imageUrl ?? '';
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      String? finalImageUrl = _uploadedUrl;
      if (_pickedImage != null) {
        final user = Supabase.instance.client.auth.currentUser;
        if (user == null) throw Exception('Not authenticated');
        finalImageUrl = await _service.uploadImage(_pickedImage!, userId: user.id);
      } else if (_imageCtrl.text.trim().isNotEmpty) {
        finalImageUrl = _imageCtrl.text.trim();
      }

      final input = CourseInput(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        imageUrl: finalImageUrl,
      );

      if (widget.editing == null) {
        final user = Supabase.instance.client.auth.currentUser;
        if (user == null) throw Exception('Not authenticated');
        await _service.create(input, instructorId: user.id);
      } else {
        await _service.update(widget.editing!.id, input);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.editing == null 
                ? '✅ Course created successfully!' 
                : '✅ Course updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Rediriger vers la liste des cours après création/modification
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => CourseListScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() {
      _pickedImage = File(picked.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editing == null ? 'Create Course' : 'Edit Course'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // Bouton pour voir la liste des cours depuis le formulaire
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => CourseListScreen()),
                (route) => false,
              );
            },
            tooltip: 'View Courses List',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) => value == null || value.isEmpty 
                    ? "Please enter a title" 
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              
              // Image Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Course Image",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _pickedImage != null
                                  ? Image.file(_pickedImage!, fit: BoxFit.cover)
                                  : (_uploadedUrl != null && _uploadedUrl!.isNotEmpty)
                                      ? Image.network(_uploadedUrl!, fit: BoxFit.cover)
                                      : Container(
                                          color: Colors.grey.shade200,
                                          child: const Icon(Icons.image, 
                                            color: Colors.grey, size: 40),
                                        ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  controller: _imageCtrl,
                                  decoration: const InputDecoration(
                                    labelText: "Image URL (optional)",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "Or upload an image from your device",
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _saving ? null : _pickImage,
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Choose Image from Gallery'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          widget.editing == null 
                              ? "Create Course" 
                              : "Update Course",
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              // Bouton pour voir la liste sans créer de cours
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => CourseListScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text('View Courses List'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}