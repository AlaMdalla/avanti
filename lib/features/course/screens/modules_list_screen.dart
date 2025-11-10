import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/module.dart';
import '../models/course.dart';

class ModulesListScreen extends StatefulWidget {
  const ModulesListScreen({super.key});

  @override
  State<ModulesListScreen> createState() => _ModulesListScreenState();
}

class _ModulesListScreenState extends State<ModulesListScreen> {
  late Future<List<Module>> _modulesFuture;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _modulesFuture = _fetchModules();
  }

  Future<List<Module>> _fetchModules() async {
    try {
      // Fetch modules - they have a course_id field for relationship
      final modulesResponse = await supabase
          .from('modules')
          .select('*')
          .order('order', ascending: true);

      print('Modules Response: $modulesResponse');

      if (modulesResponse == null) {
        return [];
      }

      final modulesList = modulesResponse is List ? modulesResponse : [modulesResponse];

      if (modulesList.isEmpty) {
        return [];
      }

      // For each module, get the related course
      final modules = <Module>[];
      
      for (final moduleData in modulesList) {
        try {
          final moduleMap = moduleData as Map<String, dynamic>;
          final courseId = moduleMap['course_id'] as String?;
          
          List<Course> courses = [];
          
          // If module has a course_id, fetch that course
          if (courseId != null && courseId.isNotEmpty) {
            try {
              final courseResponse = await supabase
                  .from('courses')
                  .select('*')
                  .eq('id', courseId)
                  .maybeSingle();
              
              if (courseResponse != null) {
                courses = [Course.fromMap(courseResponse as Map<String, dynamic>)];
              }
            } catch (e) {
              print('Error fetching course: $e');
            }
          }
          
          final module = Module(
            id: moduleMap['id'] as String,
            title: moduleMap['title'] as String,
            description: moduleMap['description'] as String?,
            order: moduleMap['order'] as int?,
            courses: courses,
            createdAt: moduleMap['created_at'] != null
                ? DateTime.tryParse(moduleMap['created_at'] as String)
                : null,
            updatedAt: moduleMap['updated_at'] != null
                ? DateTime.tryParse(moduleMap['updated_at'] as String)
                : null,
          );
          
          modules.add(module);
        } catch (e) {
          print('Error parsing module: $e');
        }
      }

      print('Successfully loaded ${modules.length} modules');
      return modules;
    } catch (e) {
      print('Error fetching modules: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Modules'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: FutureBuilder<List<Module>>(
        future: _modulesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final modules = snapshot.data ?? [];

          if (modules.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.library_books_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No modules available yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back soon for new content!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: modules.length,
            itemBuilder: (context, index) {
              final module = modules[index];
              return _ModuleCard(module: module);
            },
          );
        },
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final Module module;

  const _ModuleCard({required this.module});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Module Header
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inversePrimary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Badge
                if (module.order != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Module ${module.order}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (module.order != null) const SizedBox(height: 8),
                // Title
                Text(
                  module.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Description
                if (module.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    module.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          // Courses Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course Count
                Row(
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${module.courses.length} Course${module.courses.length != 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                if (module.courses.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  // Courses List
                  ...module.courses.asMap().entries.map((entry) {
                    final course = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  course.title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (course.description != null)
                                  Text(
                                    course.description!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ] else
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'No courses added yet',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Metadata Footer
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID: ${module.id.substring(0, 8)}...',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                if (module.createdAt != null)
                  Text(
                    'Created: ${module.createdAt!.year}-${module.createdAt!.month.toString().padLeft(2, '0')}-${module.createdAt!.day.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
