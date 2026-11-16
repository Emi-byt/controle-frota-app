class VehicleModel {
  final int? id;
  final String placa;
  final String marca;
  final String modelo;
  final int ano;

  const VehicleModel({
    this.id,
    required this.placa,
    required this.marca,
    required this.modelo,
    required this.ano,
  });

  // Converte os dados recebidos da API em um veículo.
  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: int.tryParse('${json['id']}'),
      placa: json['placa']?.toString() ?? '',
      marca: json['marca']?.toString() ?? '',
      modelo: json['modelo']?.toString() ?? '',
      ano: int.tryParse('${json['ano']}') ?? 0,
    );
  }

  // Converte o veículo em JSON para enviar à API.
  Map<String, dynamic> toJson() {
    return {'placa': placa, 'marca': marca, 'modelo': modelo, 'ano': ano};
  }
}
