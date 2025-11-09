import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../lesson/domain/usecases/get_lessons_by_module.dart';
import '../../../lesson/presentation/pages/lesson_form_page.dart';
import '../../../lesson/presentation/pages/lesson_page.dart';
import 'package:e_learning_project/features/lesson/presentation/bloc/lesson_bloc.dart';
import 'package:e_learning_project/features/lesson/presentation/bloc/lesson_event.dart';
import '../../../formateur/presentation/pages/formateur_page.dart';
import '../../../formateur/presentation/bloc/formateur_bloc.dart';
import '../../../formateur/data/datasources/formateur_remote_data_source.dart';
import '../../../formateur/data/repositories/formateur_repository_impl.dart';
import '../../../formateur/domain/usecases/get_all_formateurs.dart';
import '../../../formateur/domain/usecases/add_formateur.dart';
import '../pages/module_form_page.dart'; // Import pour le formulaire de module

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
        builder: (_) => BlocProvider(
          create: (_) => LessonBloc(widget.getLessonsUseCase)..add(LoadLessons(moduleId)),
          child: LessonPage(module_id: moduleId),
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

  // ✅ NOUVELLE MÉTHODE : Ouvrir le formulaire d'ajout de module
  void _openAddModuleForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ModuleFormPage(),
      ),
    ).then((result) {
      // Recharger les modules si un nouveau a été ajouté
      if (result == true) {
        fetchModules();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modules"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
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
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.folder_open, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        "Aucun module trouvé",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _openAddModuleForm,
                        child: const Text("Créer votre premier module"),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchModules,
                  child: ListView.builder(
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
                          leading: const CircleAvatar(
                            backgroundColor: Colors.indigo,
                            child: Icon(Icons.book, color: Colors.white),
                          ),
                          title: Text(
                            module['title'] ?? 'Sans titre',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                module['description'] ?? 'Aucune description',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                                  const SizedBox(width: 4),
                                  Text(
                                    module['created_at'] != null 
                                        ? _formatDate(module['created_at'])
                                        : 'Date inconnue',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
                          onTap: () => _openLessonPage(module['id'] as String),
                        ),
                      );
                    },
                  ),
                ),

      // ✅ BOUTONS FLOTTANTS MULTIPLES
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Bouton pour ajouter un module
          FloatingActionButton(
            onPressed: _openAddModuleForm,
            heroTag: "add_module",
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          // Bouton pour ajouter un formateur
          FloatingActionButton(
            onPressed: _openAddFormateurPage,
            heroTag: "add_formateur",
            mini: true,
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            child: const Icon(Icons.person_add),
          ),
          const SizedBox(height: 10),
          // Bouton pour voir la liste des formateurs
          FloatingActionButton(
            onPressed: _openFormateurListPage,
            heroTag: "view_formateurs",
            mini: true,
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            child: const Icon(Icons.people),
          ),
        ],
      ),
    );
  }

  // Méthode pour formater la date
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Date invalide';
    }
  }
}