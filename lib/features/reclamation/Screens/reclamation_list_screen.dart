import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReclamationListScreen extends StatefulWidget {
  const ReclamationListScreen({super.key});

  @override
  State<ReclamationListScreen> createState() => _ReclamationListScreenState();
}

class _ReclamationListScreenState extends State<ReclamationListScreen> {
  List<Map<String, dynamic>> reclamations = [];
  bool _loading = true;

  Future<void> _loadReclamations() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final data = await Supabase.instance.client
          .from('reclamations')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      setState(() {
        reclamations = List<Map<String, dynamic>>.from(data);
        _loading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur : $e")));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadReclamations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Réclamations"),
        backgroundColor: Colors.deepPurple,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : reclamations.isEmpty
              ? const Center(
                  child: Text("Aucune réclamation trouvée."),
                )
              : ListView.builder(
                  itemCount: reclamations.length,
                  itemBuilder: (context, index) {
                    final r = reclamations[index];
                    final status = r['status'] ?? 'En attente';
                    return Card(
                      margin: const EdgeInsets.all(10),
                      elevation: 3,
                      child: ListTile(
                        title: Text(r['title']),
                        subtitle: Text(r['description']),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: status == 'Résolue'
                                ? Colors.green
                                : status == 'En cours'
                                    ? Colors.orange
                                    : Colors.redAccent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
