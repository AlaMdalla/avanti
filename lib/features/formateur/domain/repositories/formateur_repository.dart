import '../entities/formateur.dart';

abstract class FormateurRepository {
  Future<void> addFormateur(Formateur formateur);
  Future<List<Formateur>> getAllFormateurs();
  Future<void> deleteFormateur(String id);
}