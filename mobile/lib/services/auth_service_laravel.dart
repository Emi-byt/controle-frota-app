import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_service.dart';

class AuthServiceLaravel extends AuthService {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://127.0.0.1:8000/api',
  );

  static String? token;

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'email': email.trim(), 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is! Map ||
            data['token'] is! String ||
            (data['token'] as String).isEmpty) {
          throw AuthException('Token não recebido do Laravel.');
        }

        token = data['token'] as String;
        return;
      }

      if (response.statusCode == 401 || response.statusCode == 422) {
        throw AuthException('E-mail ou senha incorretos.');
      }

      throw AuthException('Erro no servidor: ${response.statusCode}');
    } on AuthException {
      rethrow;
    } on TimeoutException {
      throw AuthException('Tempo de conexão esgotado.');
    } on http.ClientException {
      throw AuthException('Não foi possível conectar ao Laravel.');
    } on FormatException {
      throw AuthException('Resposta inválida do servidor.');
    }
  }

  @override
  Future<void> signOut() async {
    final currentToken = token;

    try {
      if (currentToken != null) {
        await http
            .post(
              Uri.parse('$baseUrl/logout'),
              headers: {
                'Accept': 'application/json',
                'Authorization': 'Bearer $currentToken',
              },
            )
            .timeout(const Duration(seconds: 10));
      }
    } finally {
      token = null;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    throw AuthException(
      'Recuperação de senha ainda não disponível no Laravel.',
    );
  }
}
