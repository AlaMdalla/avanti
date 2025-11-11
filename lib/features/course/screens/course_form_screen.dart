import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/course.dart';
import '../services/course_service.dart';
import 'course_list_screen.dart';
import '../../../core/utils/validators.dart';
import 'package:file_picker/file_picker.dart';
import '../models/instructor.dart';
import '../services/instructor_service.dart';

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
  final _instructorService = InstructorService();
  bool _saving = false;
  final _picker = ImagePicker();
  File? _pickedImage;
  File? _pickedPdf;
  String? _uploadedUrl;
  String? _uploadedPdfUrl;
  String? _pdfFileName;
  List<Instructor> _instructors = [];
  String? _selectedInstructorId;
  bool _loadingInstructors = true;

  @override
  void initState() {
    super.initState();
    _loadInstructors();
    if (widget.editing != null) {
      _titleCtrl.text = widget.editing!.title;
      _descCtrl.text = widget.editing!.description ?? '';
      _uploadedUrl = widget.editing!.imageUrl;
      _uploadedPdfUrl = widget.editing!.pdfUrl;
      _imageCtrl.text = widget.editing!.imageUrl ?? '';
      _selectedInstructorId = widget.editing!.instructorId;
      if (_uploadedPdfUrl != null) {
        _pdfFileName = _uploadedPdfUrl!.split('/').last;
      }
    }
  }

  Future<void> _loadInstructors() async {
    try {
      final instructors = await _instructorService.list();
      setState(() {
        _instructors = instructors;
        _loadingInstructors = false;
        // Set default instructor to current user if creating new course
        if (widget.editing == null && _selectedInstructorId == null && _instructors.isNotEmpty) {
          _selectedInstructorId = _instructors.first.id;
        }
      });
    } catch (e) {
      setState(() => _loadingInstructors = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading instructors: $e')),
        );
      }
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
    if (_selectedInstructorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an instructor')),
      );
      return;
    }

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

      // If a PDF is picked, upload it
      String? finalPdfUrl = _uploadedPdfUrl;
      if (_pickedPdf != null) {
        final user = Supabase.instance.client.auth.currentUser;
        if (user == null) throw Exception('Not authenticated');
        finalPdfUrl = await _service.uploadPdf(_pickedPdf!, userId: user.id);
      }

      final input = CourseInput(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        imageUrl: finalImageUrl,
        pdfUrl: finalPdfUrl,
      );
      if (widget.editing == null) {
        await _service.create(input, instructorId: _selectedInstructorId!);
      } else {
        await _service.update(widget.editing!.id, input);
      }
      if (mounted) Navigator.pop(context);
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

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    setState(() {
      _pickedImage = File(picked.path);
    });
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null) return;
    setState(() {
      _pickedPdf = File(result.files.single.path!);
      _pdfFileName = result.files.single.name;
    });
  }

  void _removePdf() {
    setState(() {
      _pickedPdf = null;
      _uploadedPdfUrl = null;
      _pdfFileName = null;
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
                decoration: const InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) => Validators.combine(v, [
                  Validators.required,
                  (val) => Validators.minLength(val, 3, fieldName: 'Title'),
                  (val) => Validators.maxLength(val, 100, fieldName: 'Title'),
                ]),
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
                validator: (v) => Validators.combine(v, [
                  Validators.required,
                  (val) => Validators.minLength(val, 10, fieldName: 'Description'),
                  (val) => Validators.maxLength(val, 500, fieldName: 'Description'),
                ]),
              ),
              const SizedBox(height: 12),
              // Instructor Dropdown
              _loadingInstructors
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    )
                  : DropdownButtonFormField<String>(
                      value: _selectedInstructorId,
                      decoration: const InputDecoration(
                        labelText: 'Instructor *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      items: _instructors
                          .map((instructor) => DropdownMenuItem(
                                value: instructor.id,
                                child: Text(instructor.name),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedInstructorId = value);
                      },
            validator: (v) =>
              (v == null || v.isEmpty) ? 'Please select an instructor' : null,
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
                    validator: (v) => v != null && v.isNotEmpty ? Validators.url(v) : null,
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
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.picture_as_pdf, color: Colors.red),
                      const SizedBox(width: 8),
                      const Text(
                        'PDF Content (Optional)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_pickedPdf != null || _pdfFileName != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.attach_file, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _pdfFileName ?? 'PDF Selected',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: _removePdf,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: _saving ? null : _pickPdf,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Choose PDF'),
                    ),
                  if (_pickedPdf == null && _uploadedPdfUrl == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'PDF is required',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
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
