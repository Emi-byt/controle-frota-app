import '../models/vehicle_model.dart';
import '../repositories/frota_repository.dart';

class VehicleService {
  final FrotaRepository _repository;

  VehicleService({FrotaRepository? repository})
    : _repository = repository ?? const LaravelFrotaRepository();

  // Consulta os veículos utilizando o Repository.
  Future<List<VehicleModel>> listar() async {
    final dados = await _repository.listar('vehicles');

    return dados.map((item) => VehicleModel.fromJson(item)).toList();
  }

  // Cadastra um novo veículo.
  Future<VehicleModel> cadastrar(VehicleModel vehicle) async {
    await _repository.salvar('vehicles', vehicle.toJson());

    // O Repository atual não retorna o registro criado.
    // Retornamos o modelo enviado para manter a assinatura
    // utilizada pelas outras partes do aplicativo.
    return vehicle;
  }

  // Exclui um veículo pelo identificador.
  Future<void> excluir(int id) async {
    await _repository.excluir('vehicles', id);
  }
}
