import '../entities/module.dart';
import '../repositories/module_repository.dart';

class GetAllModules {
  final ModuleRepository repository;

  GetAllModules(this.repository);

  Future<List<Module>> call() {
    return repository.getAllModules();
  }
}
