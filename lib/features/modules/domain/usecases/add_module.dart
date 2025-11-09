// features/modules/domain/usecases/add_module.dart
import '../repositories/module_repository.dart';

class AddModule {
  final ModuleRepository repository;

  AddModule(this.repository);

  Future<void> call(String title, String description) async {
    await repository.addModule(title, description);
  }
}