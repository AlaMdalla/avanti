import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/course.dart';
import '../services/course_service.dart';

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
      // If an image is picked, upload it and use resulting public URL
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
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    setState(() {
      _pickedImage = File(picked.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.editing == null ? 'Create Course' : 'Edit Course')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _pickedImage != null
                          ? Image.file(_pickedImage!, fit: BoxFit.cover)
                          : (_uploadedUrl != null && _uploadedUrl!.isNotEmpty)
                              ? Image.network(_uploadedUrl!, fit: BoxFit.cover)
                              : Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.image, color: Colors.grey),
                                ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _imageCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Image URL (optional)',
                        helperText: 'Leave empty if you will upload an image',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: _saving ? null : _pickImage,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Pick image'),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _submit,
                  child: Text(_saving ? 'Saving…' : (widget.editing == null ? 'Create' : 'Save changes')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
