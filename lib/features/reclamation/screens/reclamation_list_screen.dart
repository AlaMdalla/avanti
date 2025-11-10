import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_reclamation_screen.dart';

class ReclamationListScreen extends StatefulWidget {
  const ReclamationListScreen({super.key});

  @override
  State<ReclamationListScreen> createState() => _ReclamationListScreenState();
}

class _ReclamationListScreenState extends State<ReclamationListScreen> {
  final _client = Supabase.instance.client;
  List<dynamic> _reclamations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReclamations();
  }

  Future<void> _fetchReclamations() async {
    setState(() => _isLoading = true);
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      final response = await _client
          .from('reclamations')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      setState(() {
        _reclamations = response;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur : $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Réclamations"),
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reclamations.isEmpty
              ? const Center(child: Text("Aucune réclamation trouvée"))
              : ListView.builder(
                  itemCount: _reclamations.length,
                  itemBuilder: (context, index) {
                    final reclamation = _reclamations[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(reclamation['title'] ?? ''),
                        subtitle: Text(reclamation['description'] ?? ''),
                        trailing: Text(reclamation['status'] ?? 'En attente'),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddReclamationScreen(
                courseId: "default_course", // tu peux adapter plus tard
                courseTitle: "Cours inconnu",
              ),
            ),
          ).then((_) => _fetchReclamations()); // Refresh après ajout
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
