import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LessonFormPage extends StatefulWidget {
  final String module_id;

  const LessonFormPage({super.key, required this.module_id});

  @override
  State<LessonFormPage> createState() => _LessonFormPageState();
}

class _LessonFormPageState extends State<LessonFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentUrlController = TextEditingController();

  // Nouvelle variable pour le type
  String _selectedType = 'video';
  final List<String> _types = ['video', 'pdf', 'quiz'];

  bool _isLoading = false;

  Future<void> _addLesson() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final client = Supabase.instance.client;
      await client.from('lessons').insert({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'type': _selectedType, // Utilisation du Dropdown
        'contentUrl': _contentUrlController.text,
        'module_id': widget.module_id,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Leçon ajoutée avec succès !')),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajouter une leçon")),
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
              // Dropdown pour le type
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: "Type de leçon",
                  border: OutlineInputBorder(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedType,
                    items: _types.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedType = value;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentUrlController,
                decoration: const InputDecoration(
                  labelText: "Lien du contenu (URL)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _addLesson,
                icon: _isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add),
                label: const Text("Ajouter la leçon"),
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
