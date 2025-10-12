class AuthRemoteDataSourceImpl {
  // Simule un login
  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return email == "elyesbejaoui@gmail.com" && password == "elyesbejaoui1";
  }

  // Simule un register
  Future<bool> register(String email, String password, String username) async {
    await Future.delayed(const Duration(seconds: 1));
    // Ici, tu peux ajouter une condition pour simuler un échec si l'email existe déjà
    return email != "alreadytaken@gmail.com";
  }
}
