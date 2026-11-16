import 'package:flutter/material.dart';
import '../../widgets/frota_list_screen.dart';
import 'fueling_form_screen.dart';

class FuelingsScreen extends StatelessWidget {
  const FuelingsScreen({super.key});
  String formattedDate(dynamic raw) {
    final s = '$raw';
    return s.length >= 10 ? '${s.substring(8, 10)}/${s.substring(5, 7)}/${s.substring(0, 4)}' : s;
  }
  @override
  Widget build(BuildContext context) => FrotaListScreen(
    title: 'Abastecimentos', resource: 'fuelings', icon: Icons.local_gas_station_rounded,
    itemTitle: (v) => '${v['vehicle'] is Map ? v['vehicle']['placa'] : 'Veículo'} • ${formattedDate(v['data'])}',
    itemSubtitle: (v) => '${v['driver'] is Map ? v['driver']['nome'] : 'Motorista'} • ${v['litros'] ?? ''} L • R\$ ${v['valor_total'] ?? ''} • ${v['posto'] ?? 'Posto não informado'}',
    onCreate: (c) => Navigator.of(c, rootNavigator: true).push<bool>(MaterialPageRoute(builder: (_) => const FuelingFormScreen())),
    onEdit: (c, v) => Navigator.of(c, rootNavigator: true).push<bool>(MaterialPageRoute(builder: (_) => FuelingFormScreen(existing: v))),
  );
}
