import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/module.dart';
import '../models/course.dart';
import '../services/module_service.dart';
import '../services/course_service.dart';
import '../../../core/utils/validators.dart';

class ModuleFormScreen extends StatefulWidget {
  final Module? editing;

  const ModuleFormScreen({
    super.key,
    this.editing,
  });

  @override
  State<ModuleFormScreen> createState() => _ModuleFormScreenState();
}

class _ModuleFormScreenState extends State<ModuleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _moduleService = ModuleService();
  final _courseService = CourseService();
  
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _orderController;
  
  List<Course> _availableCourses = [];
  List<String> _selectedCourseIds = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.editing?.title ?? '');
    _descriptionController = TextEditingController(text: widget.editing?.description ?? '');
    _orderController = TextEditingController(text: widget.editing?.order?.toString() ?? '');
    _selectedCourseIds = widget.editing?.courses.map((c) => c.id).toList() ?? [];
    _loadAvailableCourses();
  }

  Future<void> _loadAvailableCourses() async {
    try {
      final courses = await _courseService.list();
      setState(() => _availableCourses = courses);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading courses: $e')),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final input = ModuleInput(
        title: _titleController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        order: int.tryParse(_orderController.text),
      );

      late String moduleId;
      if (widget.editing != null) {
        await _moduleService.update(widget.editing!.id, input);
        moduleId = widget.editing!.id;
      } else {
        final newModule = await _moduleService.create(input);
        moduleId = newModule.id;
      }

      // Save the selected courses to the module_courses junction table
      final supabase = Supabase.instance.client;
      
      // First, delete existing associations for this module
      try {
        await supabase
            .from('module_courses')
            .delete()
            .eq('module_id', moduleId);
      } catch (e) {
        print('Error removing old courses: $e');
      }

      // Then add new course associations
      for (final courseId in _selectedCourseIds) {
        try {
          await _moduleService.addCourseToModule(moduleId, courseId);
        } catch (e) {
          print('Error adding course $courseId: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error adding course: $e')),
            );
          }
          return;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Module ${widget.editing != null ? 'updated' : 'created'} with ${_selectedCourseIds.length} course${_selectedCourseIds.length != 1 ? 's' : ''}')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editing != null ? 'Edit Module' : 'Create Module'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Module Title',
                  hintText: 'e.g., Introduction to Flutter',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => Validators.combine(v, [
                  Validators.required,
                  (val) => Validators.minLength(val, 3, fieldName: 'Title'),
                  (val) => Validators.maxLength(val, 100, fieldName: 'Title'),
                ]),
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Enter module description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (v) => Validators.maxLength(v, 500, fieldName: 'Description'),
              ),
              const SizedBox(height: 16),

              // Order Field
              TextFormField(
                controller: _orderController,
                decoration: const InputDecoration(
                  labelText: 'Order (optional)',
                  hintText: 'e.g., 1, 2, 3',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => Validators.nonNegativeInteger(v, required: false, fieldName: 'Order'),
              ),
              const SizedBox(height: 24),

              // Courses Section
              Text(
                'Add Courses to Module',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              
              if (_availableCourses.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('No courses available'),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _availableCourses.length,
                  itemBuilder: (context, index) {
                    final course = _availableCourses[index];
                    final isSelected = _selectedCourseIds.contains(course.id);
                    
                    return CheckboxListTile(
                      title: Text(course.title),
                      subtitle: Text(course.description ?? ''),
                      value: isSelected,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedCourseIds.add(course.id);
                          } else {
                            _selectedCourseIds.remove(course.id);
                          }
                        });
                      },
                    );
                  },
                ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.editing != null ? 'Update Module' : 'Create Module'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
