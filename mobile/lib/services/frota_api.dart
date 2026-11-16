import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service_laravel.dart';

class FrotaApi {
  static Uri url(String resource, [int? id]) => Uri.parse(
    '${AuthServiceLaravel.baseUrl}/$resource${id == null ? '' : '/$id'}');

  static Map<String, String> get headers {
    final token = AuthServiceLaravel.token;
    if (token == null || token.isEmpty) throw Exception('Sessão encerrada. Faça login novamente.');
    return {'Accept':'application/json','Content-Type':'application/json','Authorization':'Bearer $token'};
  }

  static dynamic decode(http.Response response) {
    if (response.statusCode == 401) throw Exception('Sessão expirada. Entre novamente.');
    if (response.statusCode == 403) throw Exception('Você não tem permissão para esta operação.');
    if (response.statusCode == 409) throw Exception(_message(response, 'Registro vinculado a outros dados.'));
    if (response.statusCode == 422) throw Exception(_message(response, 'Dados inválidos. Confira os campos.'));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_message(response, 'Erro ${response.statusCode} ao consultar o servidor.'));
    }
    if (response.body.trim().isEmpty) return null;
    return jsonDecode(response.body);
  }

  static String _message(http.Response response, String fallback) {
    try {
      final data=jsonDecode(response.body);
      if (data is Map && data['message'] is String) return data['message'];
    } catch (_) {}
    return fallback;
  }

  static Future<List<Map<String,dynamic>>> list(String resource) async {
    final response=await http.get(url(resource),headers:headers).timeout(const Duration(seconds:15));
    final decoded=decode(response);
    final values=decoded is List ? decoded : decoded is Map ? decoded['data'] : null;
    if(values is! List) throw Exception('Formato de resposta inesperado.');
    return values.map((item)=>Map<String,dynamic>.from(item as Map)).toList();
  }

  static Future<void> save(String resource, Map<String,dynamic> data, {int? id}) async {
    final response=await (id==null
      ? http.post(url(resource),headers:headers,body:jsonEncode(data))
      : http.put(url(resource,id),headers:headers,body:jsonEncode(data)))
      .timeout(const Duration(seconds:15));
    decode(response);
  }

  static Future<void> delete(String resource,int id) async {
    final response=await http.delete(url(resource,id),headers:headers).timeout(const Duration(seconds:15));
    decode(response);
  }
}
