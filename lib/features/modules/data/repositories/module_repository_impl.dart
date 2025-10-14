import '../../domain/entities/module.dart';
import '../../domain/repositories/module_repository.dart';
import '../datasources/module_remote_data_source.dart';

class ModuleRepositoryImpl implements ModuleRepository {
  final ModuleRemoteDataSource remoteDataSource;

  ModuleRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Module>> getAllModules() {
    return remoteDataSource.getAllModules();
  }

  @override
  Future<void> addModule(String title, String description) {
    return remoteDataSource.addModule(title, description);
  }
}
