import '../entities/formateur.dart';
import '../repositories/formateur_repository.dart';

class GetAllFormateurs {
  final FormateurRepository repository;
  GetAllFormateurs(this.repository);

  Future<List<Formateur>> call() async {
    return await repository.getAllFormateurs();
  }
}