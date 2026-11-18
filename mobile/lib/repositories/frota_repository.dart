import '../services/frota_api.dart';

/// Contrato de acesso aos dados da frota.
///
/// Permite que a interface utilize diferentes implementações
/// sem depender diretamente das requisições HTTP.
abstract class FrotaRepository {
  Future<List<Map<String, dynamic>>> listar(String recurso);

  Future<void> salvar(String recurso, Map<String, dynamic> dados, {int? id});

  Future<void> excluir(String recurso, int id);
}

/// Implementação que utiliza a API Laravel.
class LaravelFrotaRepository implements FrotaRepository {
  const LaravelFrotaRepository();

  @override
  Future<List<Map<String, dynamic>>> listar(String recurso) {
    return FrotaApi.list(recurso);
  }

  @override
  Future<void> salvar(String recurso, Map<String, dynamic> dados, {int? id}) {
    return FrotaApi.save(recurso, dados, id: id);
  }

  @override
  Future<void> excluir(String recurso, int id) {
    return FrotaApi.delete(recurso, id);
  }
}
