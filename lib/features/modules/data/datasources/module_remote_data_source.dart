import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/module_model.dart';

abstract class ModuleRemoteDataSource {
  Future<List<ModuleModel>> getAllModules();
  Future<void> addModule(String title, String description);
}

class ModuleRemoteDataSourceImpl implements ModuleRemoteDataSource {
  final SupabaseClient client;

  ModuleRemoteDataSourceImpl(this.client);

  @override
  Future<List<ModuleModel>> getAllModules() async {
    final response = await client.from('modules').select();
    return (response as List)
        .map((data) => ModuleModel.fromJson(data))
        .toList();
  }

  @override
  Future<void> addModule(String title, String description) async {
    await client.from('modules').insert({
      'title': title,
      'description': description,
    });
  }
}
