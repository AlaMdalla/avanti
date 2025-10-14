import 'package:equatable/equatable.dart';

abstract class ModuleEvent extends Equatable {
  const ModuleEvent();

  @override
  List<Object?> get props => [];
}

class LoadModules extends ModuleEvent {}

class AddNewModule extends ModuleEvent {
  final String title;
  final String description;

  const AddNewModule(this.title, this.description);

  @override
  List<Object?> get props => [title, description];
}
