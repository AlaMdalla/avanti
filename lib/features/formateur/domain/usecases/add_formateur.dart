import '../entities/formateur.dart';
import '../repositories/formateur_repository.dart';

class AddFormateur {
  final FormateurRepository repository;
  AddFormateur(this.repository);

  Future<void> call(Formateur formateur) async {
    await repository.addFormateur(formateur);
  }
}