import '../repositories/formateur_repository.dart';

class DeleteFormateur {
  final FormateurRepository repository;
  DeleteFormateur(this.repository);

  Future<void> call(String id) async {
    await repository.deleteFormateur(id);
  }
}
