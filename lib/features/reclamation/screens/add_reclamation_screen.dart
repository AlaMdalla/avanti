import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/reclamation_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddReclamationScreen extends StatefulWidget {
  final String courseId;
  final String courseTitle;

  const AddReclamationScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  State<AddReclamationScreen> createState() => _AddReclamationScreenState();
}

class _AddReclamationScreenState extends State<AddReclamationScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _service = ReclamationService();
  bool _isLoading = false;
  bool _isAnalyzing = false;
  String? _suggestedCategory;
  String? _aiFeedback;

  Future<void> _submitReclamation() async {
    if (_titleController.text.isEmpty || _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs.")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _service.addReclamation(
        courseId: widget.courseId,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Réclamation envoyée ✅")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 🔹 Analyse IA du texte via API externe (ex. OpenAI ou HuggingFace)
  Future<void> _analyzeWithAI() async {
    if (_descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez d’abord écrire une description.")),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _suggestedCategory = null;
      _aiFeedback = null;
    });

    try {
      // Exemple d'appel à une API d’analyse IA locale ou externe
      final response = await http.post(
        Uri.parse("https://api-inference.huggingface.co/models/facebook/bart-large-mnli"),
        headers: {"Authorization": "Bearer VOTRE_TOKEN_IA"}, // 👉 remplace par ton token API
        body: jsonEncode({
          "inputs": _descController.text,
          "parameters": {
            "candidate_labels": ["Problème technique", "Pédagogique", "Suggestion", "Autre"]
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final label = data["labels"][0];
        final score = (data["scores"][0] * 100).toStringAsFixed(1);

        setState(() {
          _suggestedCategory = label;
          _aiFeedback = "Cette réclamation semble être de type **$label** ($score %).";
        });
      } else {
        throw Exception("Erreur lors de l'analyse IA (${response.statusCode})");
      }
    } catch (e) {
      setState(() {
        _aiFeedback = "Impossible d’analyser le texte : $e";
      });
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Réclamation - ${widget.courseTitle}"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Sujet",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: "Description (explique le problème)",
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 20),

              // 🔹 Bouton d'analyse IA
              ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _analyzeWithAI,
                icon: const Icon(Icons.smart_toy),
                label: _isAnalyzing
                    ? const Text("Analyse en cours...")
                    : const Text("Analyser avec l'IA"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),

              if (_aiFeedback != null) ...[
                const SizedBox(height: 16),
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      _aiFeedback!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // 🔹 Bouton d'envoi final
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitReclamation,
                icon: const Icon(Icons.send),
                label: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Envoyer"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
