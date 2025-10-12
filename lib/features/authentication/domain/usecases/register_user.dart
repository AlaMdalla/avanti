import '../repositories/auth_repository.dart';

class RegisterUser {
  final AuthRepository repository;

  RegisterUser(this.repository);

  Future<bool> call(String email, String password, String username) {
    return repository.register(email, password, username);
  }
}
