import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/vehicle_model.dart';

class VehicleService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/vehicles';

  Future<List<VehicleModel>> listar() async {
    final response = await http
        .get(Uri.parse(baseUrl), headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Erro ao carregar veículos.');
    }

    final List<dynamic> dados = jsonDecode(response.body);

    return dados.map((item) => VehicleModel.fromJson(item)).toList();
  }

  Future<VehicleModel> cadastrar(VehicleModel vehicle) async {
    final response = await http
        .post(
          Uri.parse(baseUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(vehicle.toJson()),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 201) {
      return VehicleModel.fromJson(jsonDecode(response.body));
    }

    if (response.statusCode == 422) {
      throw Exception('Dados inválidos ou placa já cadastrada.');
    }

    throw Exception('Erro ao cadastrar veículo: ${response.statusCode}');
  }

  Future<void> excluir(int id) async {
    final response = await http
        .delete(
          Uri.parse('$baseUrl/$id'),
          headers: {'Accept': 'application/json'},
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Não foi possível excluir o veículo.');
    }
  }
}
