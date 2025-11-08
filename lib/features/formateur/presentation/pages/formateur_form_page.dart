import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

// Corrigez les chemins d'import - utilisez des chemins relatifs corrects
import '../../data/datasources/formateur_remote_data_source.dart';
import '../../domain/entities/formateur.dart';

class FormateurFormPage extends StatefulWidget {
  const FormateurFormPage({super.key});

  @override
  State<FormateurFormPage> createState() => _FormateurFormPageState();
}

class _FormateurFormPageState extends State<FormateurFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _specialityController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final newFormateur = Formateur(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        speciality: _specialityController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        createdAt: DateTime.now(),
      );

      try {
        final dataSource = FormateurRemoteDataSourceImpl(Supabase.instance.client);
        await dataSource.addFormateur(newFormateur);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Formateur ajouté avec succès")),
        );
        
        Navigator.pop(context);
        
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Erreur : $e")),
        );
      }

      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajouter un formateur")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nom du formateur",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "Veuillez entrer le nom" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _specialityController,
                decoration: const InputDecoration(
                  labelText: "Spécialité",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "Veuillez entrer la spécialité" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "Veuillez entrer un email" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: "Adresse",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitForm,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_isLoading ? "Enregistrement..." : "Enregistrer"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specialityController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}