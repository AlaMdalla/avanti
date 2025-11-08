import '../../domain/entities/formateur.dart';
import '../../domain/repositories/formateur_repository.dart';
import '../datasources/formateur_remote_data_source.dart';

class FormateurRepositoryImpl implements FormateurRepository {
  final FormateurRemoteDataSource remoteDataSource;

  FormateurRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> addFormateur(Formateur formateur) {
    return remoteDataSource.addFormateur(formateur);
  }

  @override
  Future<List<Formateur>> getAllFormateurs() {
    return remoteDataSource.getAllFormateurs();
  }

  @override
  Future<void> deleteFormateur(String id) {
    return remoteDataSource.deleteFormateur(id);
  }
}