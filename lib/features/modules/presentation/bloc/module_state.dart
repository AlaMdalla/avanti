import 'package:equatable/equatable.dart';
import '../../domain/entities/module.dart';

abstract class ModuleState extends Equatable {
  const ModuleState();

  @override
  List<Object?> get props => [];
}

class ModuleInitial extends ModuleState {}

class ModuleLoading extends ModuleState {}

class ModuleLoaded extends ModuleState {
  final List<Module> modules;

  const ModuleLoaded(this.modules);

  @override
  List<Object?> get props => [modules];
}

class ModuleError extends ModuleState {
  final String message;

  const ModuleError(this.message);

  @override
  List<Object?> get props => [message];
}
