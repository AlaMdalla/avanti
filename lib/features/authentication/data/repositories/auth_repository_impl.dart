// auth_repository_impl.dart
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSourceImpl remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<bool> login(String email, String password) {
    return remoteDataSource.login(email, password);
  }

  @override
  Future<bool> register(String email, String password, String username) {
    return remoteDataSource.register(email, password, username);
  }
}
