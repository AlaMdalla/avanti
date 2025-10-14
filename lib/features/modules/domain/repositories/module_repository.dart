import '../entities/module.dart';

abstract class ModuleRepository {
  Future<List<Module>> getAllModules();
  Future<void> addModule(String title, String description);
}
