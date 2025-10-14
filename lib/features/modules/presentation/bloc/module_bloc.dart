import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_all_modules.dart';
import '../../domain/usecases/add_module.dart';
import 'module_event.dart';
import 'module_state.dart';

class ModuleBloc extends Bloc<ModuleEvent, ModuleState> {
  final GetAllModules getAllModules;
  final AddModule addModule;

  ModuleBloc({
    required this.getAllModules,
    required this.addModule,
  }) : super(ModuleInitial()) {
    on<LoadModules>(_onLoadModules);
    on<AddNewModule>(_onAddModule);
  }

  Future<void> _onLoadModules(
      LoadModules event, Emitter<ModuleState> emit) async {
    emit(ModuleLoading());
    try {
      final modules = await getAllModules();
      emit(ModuleLoaded(modules));
    } catch (e) {
      emit(ModuleError("Erreur lors du chargement des modules"));
    }
  }

  Future<void> _onAddModule(
      AddNewModule event, Emitter<ModuleState> emit) async {
    try {
      await addModule(event.title, event.description);
      final modules = await getAllModules();
      emit(ModuleLoaded(modules));
    } catch (e) {
      emit(ModuleError("Erreur lors de l’ajout du module"));
    }
  }
}
