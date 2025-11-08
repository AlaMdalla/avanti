import '../../domain/entities/formateur.dart';

abstract class FormateurEvent {}

class LoadFormateurs extends FormateurEvent {}

class AddFormateurEvent extends FormateurEvent {
  final Formateur formateur;
  AddFormateurEvent(this.formateur);
}

class DeleteFormateurEvent extends FormateurEvent {
  final String id;
  DeleteFormateurEvent(this.id);
}
