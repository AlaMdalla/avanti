import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // ✅ AJOUTEZ CET IMPORT
import '../../../lesson/domain/entities/lesson.dart';
import '../../../lesson/domain/usecases/get_lessons_by_module.dart';
import '../../../lesson/presentation/pages/lesson_form_page.dart';
import '../../../lesson/presentation/pages/lesson_page.dart';
import '../../../formateur/presentation/pages/formateur_page.dart';
import '../../../formateur/presentation/bloc/formateur_bloc.dart';
import '../../../formateur/data/datasources/formateur_remote_data_source.dart';
import '../../../formateur/data/repositories/formateur_repository_impl.dart';
import '../../../formateur/domain/usecases/get_all_formateurs.dart';
import '../../../formateur/domain/usecases/add_formateur.dart';

class ModuleListPage extends StatefulWidget {
  final GetLessonsByModule getLessonsUseCase;

  const ModuleListPage({super.key, required this.getLessonsUseCase});

  @override
  State<ModuleListPage> createState() => _ModuleListPageState();
}

class _ModuleListPageState extends State<ModuleListPage> {
  List<Map<String, dynamic>> modules = [];
  bool isLoadingModules = true;

  // ✅ Création du FormateurBloc
  FormateurBloc get _formateurBloc {
    final remoteDataSource = FormateurRemoteDataSourceImpl(Supabase.instance.client);
    final repository = FormateurRepositoryImpl(remoteDataSource);
    final getAllFormateurs = GetAllFormateurs(repository);
    final addFormateur = AddFormateur(repository);
    
    return FormateurBloc(
      getAllFormateurs: getAllFormateurs,
      addFormateur: addFormateur,
    );
  }

  @override
  void initState() {
    super.initState();
    fetchModules();
  }

  Future<void> fetchModules() async {
    try {
      final response = await Supabase.instance.client.from('modules').select('*');
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

  void _openAddFormateurPage() {
    Navigator.pushNamed(context, '/add-formateur');
  }

  // ✅ CORRIGÉ : Envelopper FormateurPage avec BlocProvider
  void _openFormateurListPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: _formateurBloc,
          child: const FormateurPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modules"),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: "Voir les formateurs",
            onPressed: _openFormateurListPage,
          ),
        ],
      ),
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
                              icon: const Icon(Icons.book_outlined, color: Colors.indigo),
                              tooltip: "Voir les leçons",
                              onPressed: () => _openLessonPage(module['id'] as String),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                              tooltip: "Ajouter une leçon",
                              onPressed: () => _openAddLessonForm(module['id'] as String),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _openAddFormateurPage,
            heroTag: "add_formateur",
            mini: true,
            child: const Icon(Icons.person_add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _openFormateurListPage,
            heroTag: "view_formateurs",
            child: const Icon(Icons.people),
          ),
        ],
      ),
    );
  }
}