import '../../domain/entities/formateur.dart';

abstract class FormateurState {}

class FormateurInitial extends FormateurState {}

class FormateurLoading extends FormateurState {}

class FormateurLoaded extends FormateurState {
  final List<Formateur> formateurs;
  FormateurLoaded(this.formateurs);
}

class FormateurError extends FormateurState {
  final String message;
  FormateurError(this.message);
}
