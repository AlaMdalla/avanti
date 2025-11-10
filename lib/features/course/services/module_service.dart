import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/module.dart';
import '../models/course.dart';

class ModuleService {
  final SupabaseClient _sb;
  static const String table = 'modules';

  ModuleService({SupabaseClient? client}) : _sb = client ?? Supabase.instance.client;

  Future<List<Module>> list({int limit = 50, int offset = 0}) async {
    final data = await _sb.from(table)
        .select('*')
        .order('order', ascending: true)
        .range(offset, offset + limit - 1);
    
    final list = data as List<dynamic>;
    final modules = <Module>[];
    
    for (final moduleData in list) {
      try {
        final moduleMap = moduleData as Map<String, dynamic>;
        final courseId = moduleMap['course_id'] as String?;
        
        List<Course> courses = [];
        
        if (courseId != null && courseId.isNotEmpty) {
          try {
            final courseResponse = await _sb
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
        
        modules.add(Module(
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
        ));
      } catch (e) {
        print('Error parsing module: $e');
      }
    }
    
    return modules;
  }

  Future<Module> getById(String id) async {
    final data = await _sb.from(table)
        .select('*')
        .eq('id', id)
        .maybeSingle();
    if (data == null) {
      throw Exception('Module not found');
    }
    
    final moduleMap = data as Map<String, dynamic>;
    final courseId = moduleMap['course_id'] as String?;
    
    List<Course> courses = [];
    
    if (courseId != null && courseId.isNotEmpty) {
      try {
        final courseResponse = await _sb
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
    
    return Module(
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
  }

  Future<Module> create(ModuleInput input) async {
    final inserted = await _sb
        .from(table)
        .insert(input.toInsert())
        .select()
        .single();
    return Module.fromMap(inserted);
  }

  Future<Module> update(String id, ModuleInput input) async {
    final updated = await _sb
        .from(table)
        .update(input.toUpdate())
        .eq('id', id)
        .select()
        .single();
    return Module.fromMap(updated);
  }

  Future<void> delete(String id) async {
    await _sb.from(table).delete().eq('id', id);
  }

  // Add a course to a module
  Future<void> addCourseToModule(String moduleId, String courseId) async {
    await _sb
        .from('module_courses')
        .insert({
          'module_id': moduleId,
          'course_id': courseId,
        });
  }

  // Remove a course from a module
  Future<void> removeCourseFromModule(String moduleId, String courseId) async {
    await _sb
        .from('module_courses')
        .delete()
        .eq('module_id', moduleId)
        .eq('course_id', courseId);
  }

  // Get all courses in a module
  Future<List<Course>> getCoursesInModule(String moduleId) async {
    final data = await _sb
        .from('module_courses')
        .select('course_id, courses(*)')
        .eq('module_id', moduleId);
    
    final list = data as List<dynamic>;
    return list
        .map((e) {
          final course = e['courses'] as Map<String, dynamic>?;
          return course;
        })
        .whereType<Map<String, dynamic>>()
        .map((e) => Course.fromMap(e))
        .toList();
  }
}
