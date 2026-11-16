import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/frota_api.dart';

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 8 ? digits.substring(0, 8) : digits;

    final buffer = StringBuffer();
    for (int i = 0; i < limited.length; i++) {
      if (i == 2 || i == 4) buffer.write('/');
      buffer.write(limited[i]);
    }

    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class FuelingFormScreen extends StatefulWidget {
  const FuelingFormScreen({super.key, this.existing});

  final Map<String, dynamic>? existing;

  @override
  State<FuelingFormScreen> createState() => _FuelingFormScreenState();
}

class _FuelingFormScreenState extends State<FuelingFormScreen> {
  final formKey = GlobalKey<FormState>();

  final date = TextEditingController();
  final price = TextEditingController();
  final liters = TextEditingController();
  final mileage = TextEditingController();
  final station = TextEditingController();

  List<Map<String, dynamic>> vehicles = [];
  List<Map<String, dynamic>> drivers = [];

  int? vehicleId;
  int? driverId;

  bool loading = true;
  bool saving = false;
  String? error;

  double? numeric(String value) =>
      double.tryParse(value.trim().replaceAll(',', '.'));

  double get total => (numeric(price.text) ?? 0) * (numeric(liters.text) ?? 0);

  String money(double value) =>
      'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  void initState() {
    super.initState();

    final old = widget.existing;

    vehicleId = (old?['vehicle_id'] as num?)?.toInt();
    driverId = (old?['driver_id'] as num?)?.toInt();

    final rawDate = '${old?['data'] ?? ''}';

    date.text = rawDate.length >= 10
        ? '${rawDate.substring(8, 10)}/${rawDate.substring(5, 7)}/${rawDate.substring(0, 4)}'
        : '';

    liters.text = '${old?['litros'] ?? ''}';
    mileage.text = '${old?['quilometragem'] ?? ''}';
    station.text = '${old?['posto'] ?? ''}';

    final oldLiters = numeric(liters.text);
    final oldTotal = double.tryParse('${old?['valor_total'] ?? ''}');

    if (oldLiters != null && oldLiters > 0 && oldTotal != null) {
      price.text = (oldTotal / oldLiters)
          .toStringAsFixed(2)
          .replaceAll('.', ',');
    }

    price.addListener(refreshTotal);
    liters.addListener(refreshTotal);

    loadOptions();
  }

  void refreshTotal() {
    if (mounted) setState(() {});
  }

  Future<void> loadOptions() async {
    try {
      final results = await Future.wait([
        FrotaApi.list('vehicles'),
        FrotaApi.list('drivers'),
      ]);

      if (!mounted) return;

      setState(() {
        vehicles = results[0];
        drivers = results[1];
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = '$e';
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    price.removeListener(refreshTotal);
    liters.removeListener(refreshTotal);

    for (final controller in [date, price, liters, mileage, station]) {
      controller.dispose();
    }

    super.dispose();
  }

  String? validateDate(String? value) {
    final text = (value ?? '').trim();

    if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(text)) {
      return 'Digite a data no formato DD/MM/AAAA';
    }

    final parts = text.split('/');

    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[2]);

    if (year < 2000 || year > 2100 || month < 1 || month > 12) {
      return 'Data inválida';
    }

    final parsed = DateTime(year, month, day);

    if (parsed.day != day || parsed.month != month || parsed.year != year) {
      return 'Data inválida';
    }

    return null;
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => saving = true);

    try {
      final parts = date.text.split('/');

      final data = <String, dynamic>{
        'vehicle_id': vehicleId,
        'driver_id': driverId,
        'data': '${parts[2]}-${parts[1]}-${parts[0]}',
        'litros': numeric(liters.text),
        'valor_total': double.parse(total.toStringAsFixed(2)),
        'quilometragem': int.parse(mileage.text.trim()),
        'posto': station.text.trim().isEmpty ? null : station.text.trim(),
      };

      await FrotaApi.save(
        'fuelings',
        data,
        id: (widget.existing?['id'] as num?)?.toInt(),
      );

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Widget numberField(
    String label,
    TextEditingController controller, {
    bool integer = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: !integer),
        decoration: InputDecoration(labelText: label),
        validator: (value) {
          final number = numeric(value ?? '');

          if (number == null || number <= 0) {
            return 'Informe um valor maior que zero';
          }

          if (integer && int.tryParse((value ?? '').trim()) == null) {
            return 'Informe uma quilometragem inteira';
          }

          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existing == null
              ? 'Novo abastecimento'
              : 'Editar abastecimento',
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? Center(child: Text(error!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Icon(
                              Icons.local_gas_station_rounded,
                              size: 46,
                              color: Color(0xFF1E3A5F),
                            ),

                            const SizedBox(height: 20),

                            DropdownButtonFormField<int>(
                              value: vehicles.any((v) => v['id'] == vehicleId)
                                  ? vehicleId
                                  : null,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Veículo',
                              ),
                              items: vehicles.map((v) {
                                return DropdownMenuItem<int>(
                                  value: (v['id'] as num).toInt(),
                                  child: Text(
                                    '${v['placa'] ?? ''} — '
                                    '${v['marca'] ?? ''} '
                                    '${v['modelo'] ?? ''}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => vehicleId = value);
                              },
                              validator: (value) =>
                                  value == null ? 'Selecione um veículo' : null,
                            ),

                            const SizedBox(height: 16),

                            DropdownButtonFormField<int>(
                              value: drivers.any((v) => v['id'] == driverId)
                                  ? driverId
                                  : null,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Motorista',
                              ),
                              items: drivers.map((v) {
                                return DropdownMenuItem<int>(
                                  value: (v['id'] as num).toInt(),
                                  child: Text(
                                    '${v['nome'] ?? ''}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => driverId = value);
                              },
                              validator: (value) => value == null
                                  ? 'Selecione um motorista'
                                  : null,
                            ),

                            const SizedBox(height: 16),

                            TextFormField(
                              controller: date,
                              keyboardType: TextInputType.number,
                              inputFormatters: [DateInputFormatter()],
                              maxLength: 10,
                              decoration: const InputDecoration(
                                labelText: 'Data do abastecimento',
                                hintText: 'DD/MM/AAAA',
                                prefixIcon: Icon(Icons.edit_calendar_outlined),
                                counterText: '',
                              ),
                              validator: validateDate,
                            ),

                            const SizedBox(height: 16),

                            numberField('Preço por litro (R\$)', price),

                            numberField('Quantidade de litros', liters),

                            numberField(
                              'Quilometragem (km)',
                              mileage,
                              integer: true,
                            ),

                            TextFormField(
                              controller: station,
                              decoration: const InputDecoration(
                                labelText: 'Posto (opcional)',
                              ),
                            ),

                            const SizedBox(height: 22),

                            Text(
                              'Valor total calculado: ${money(total)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 20),

                            ElevatedButton.icon(
                              onPressed: saving ? null : save,
                              icon: const Icon(Icons.save_outlined),
                              label: Text(
                                saving ? 'Salvando...' : 'Salvar abastecimento',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
