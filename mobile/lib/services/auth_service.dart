class AuthService {
  Future<void> signIn({required String email, required String password}) async {
    throw UnimplementedError('Use AuthServiceLaravel.');
  }

  Future<void> signOut() async {
    throw UnimplementedError('Use AuthServiceLaravel.');
  }

  Future<void> sendPasswordResetEmail(String email) async {
    throw AuthException('Recuperação de senha ainda não disponível.');
  }
}

class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
