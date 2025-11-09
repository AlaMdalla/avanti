import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:e_learning_project/features/lesson/domain/entities/lesson.dart';

class LessonFormPage extends StatefulWidget {
  final String module_id;
  final Lesson? lesson; // Si null, ajout ; sinon modification

  const LessonFormPage({super.key, required this.module_id, this.lesson});

  @override
  State<LessonFormPage> createState() => _LessonFormPageState();
}

class _LessonFormPageState extends State<LessonFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentUrlController = TextEditingController();
  final _durationController = TextEditingController();

  String _selectedType = 'video';
  final List<String> _types = ['video', 'pdf'];

  String? _pickedFilePath;
  String? _pickedFileName;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.lesson != null) {
      _titleController.text = widget.lesson!.title;
      _descriptionController.text = widget.lesson!.description;
      _contentUrlController.text = widget.lesson!.contentUrl ?? '';
      _durationController.text = widget.lesson!.duration?.toString() ?? '';
      _selectedType = widget.lesson!.type;
    }
  }

  Future<void> _saveLesson() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final client = Supabase.instance.client;

      // Si un fichier local a été sélectionné, on utilise son chemin
      if (_pickedFilePath != null && _contentUrlController.text.isEmpty) {
        _contentUrlController.text = _pickedFilePath!;
      }

      if (widget.lesson == null) {
        // Ajouter
        await client.from('lessons').insert({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'type': _selectedType,
          'content_url': _contentUrlController.text,
          'module_id': widget.module_id,
          'duration': int.tryParse(_durationController.text),
          'updated_at': DateTime.now().toIso8601String(),
        });
      } else {
        // Modifier
        await client.from('lessons').update({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'type': _selectedType,
          'content_url': _contentUrlController.text,
          'duration': int.tryParse(_durationController.text),
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', widget.lesson!.id);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.lesson == null
                ? '✅ Leçon ajoutée !'
                : '✅ Leçon modifiée !'),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Erreur : $error')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentUrlController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson == null ? "Ajouter une leçon" : "Modifier la leçon"),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Titre",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Entrez un titre" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Entrez une description" : null,
              ),
              const SizedBox(height: 16),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: "Type de leçon",
                  border: OutlineInputBorder(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedType,
                    items: _types
                        .map((type) =>
                            DropdownMenuItem(value: type, child: Text(type.toUpperCase())))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedType = value);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // File picker / content URL
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _contentUrlController,
                      decoration: const InputDecoration(
                        labelText: "Lien du contenu (URL)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                            final result = await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['pdf', 'mp4', 'mov', 'webm'],
                            );
                            if (result == null) return;
                            final path = result.files.single.path;
                            if (path == null) return;
                            setState(() {
                              _pickedFilePath = path;
                              _pickedFileName = p.basename(path);
                              // Auto-set type depending on extension
                              final lower = _pickedFileName!.toLowerCase();
                              if (lower.endsWith('.pdf')) {
                                _selectedType = 'pdf';
                              } else {
                                _selectedType = 'video';
                              }
                            });
                          },
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Choisir un fichier'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _pickedFileName ?? 'Aucun fichier sélectionné',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Durée (en secondes)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveLesson,
                icon: _isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(widget.lesson == null ? Icons.add : Icons.edit),
                label: Text(widget.lesson == null ? "Ajouter la leçon" : "Modifier la leçon"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}