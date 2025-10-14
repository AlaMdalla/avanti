import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../lesson/domain/entities/lesson.dart';
import '../../../lesson/domain/usecases/get_lessons_by_module.dart';
import '../../../lesson/presentation/pages/lesson_form_page.dart';
import '../../../lesson/presentation/pages/lesson_page.dart';

class ModuleListPage extends StatefulWidget {
  final GetLessonsByModule getLessonsUseCase;

  const ModuleListPage({super.key, required this.getLessonsUseCase});

  @override
  State<ModuleListPage> createState() => _ModuleListPageState();
}

class _ModuleListPageState extends State<ModuleListPage> {
  List<Map<String, dynamic>> modules = [];
  bool isLoadingModules = true;

  @override
  void initState() {
    super.initState();
    fetchModules();
  }

  Future<void> fetchModules() async {
    try {
      final response =
          await Supabase.instance.client.from('modules').select('*');
      setState(() {
        modules = List<Map<String, dynamic>>.from(response);
        isLoadingModules = false;
      });
    } catch (e) {
      setState(() => isLoadingModules = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Erreur de chargement des modules : $e")),
      );
    }
  }

  Future<void> _openAddLessonForm(String moduleId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LessonFormPage(module_id: moduleId),
      ),
    );

    // Si une leçon a été ajoutée, on recharge les modules
    if (result == true) {
      fetchModules();
    }
  }

  void _openLessonPage(String moduleId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LessonPage(
          module_id: moduleId,
          getLessonsUseCase: widget.getLessonsUseCase,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Modules")),
      body: isLoadingModules
          ? const Center(child: CircularProgressIndicator())
          : modules.isEmpty
              ? const Center(
                  child: Text(
                    "Aucun module trouvé.",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: modules.length,
                  itemBuilder: (context, index) {
                    final module = modules[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          module['title'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(module['description'] ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.book_outlined,
                                  color: Colors.indigo),
                              tooltip: "Voir les leçons",
                              onPressed: () =>
                                  _openLessonPage(module['id'] as String),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline,
                                  color: Colors.green),
                              tooltip: "Ajouter une leçon",
                              onPressed: () =>
                                  _openAddLessonForm(module['id'] as String),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
