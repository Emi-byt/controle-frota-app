import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service_laravel.dart';
import '../../repositories/frota_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FrotaRepository repository = const LaravelFrotaRepository();
  bool loading = true;
  String? error;

  int vehicles = 0;
  int drivers = 0;
  int fuelings = 0;

  List<Map<String, dynamic>> records = [];

  late int selectedMonth;
  late int selectedYear;

  final monthNames = const [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    selectedMonth = now.month;
    selectedYear = now.year;

    load();
  }

  double parseValue(dynamic value) {
    if (value is num) return value.toDouble();

    return double.tryParse('$value'.trim().replaceAll(',', '.')) ?? 0;
  }

  DateTime? parseDate(dynamic value) {
    final text = '$value';

    if (text.length < 10) return null;

    return DateTime.tryParse(text.substring(0, 10));
  }

  String currency(double value) {
    final parts = value.toStringAsFixed(2).split('.');

    final formatted = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );

    return 'R\$ $formatted,${parts[1]}';
  }

  DateTime get selectedDate => DateTime(selectedYear, selectedMonth);

  double spentBetween(DateTime start, DateTime end) {
    double sum = 0;

    for (final record in records) {
      final date = parseDate(record['data']);

      if (date == null) continue;

      if (!date.isBefore(start) && date.isBefore(end)) {
        sum += parseValue(record['valor_total']);
      }
    }

    return sum;
  }

  int countBetween(DateTime start, DateTime end) {
    int count = 0;

    for (final record in records) {
      final date = parseDate(record['data']);

      if (date == null) continue;

      if (!date.isBefore(start) && date.isBefore(end)) {
        count++;
      }
    }

    return count;
  }

  double get monthlySpent {
    return spentBetween(
      selectedDate,
      DateTime(selectedYear, selectedMonth + 1),
    );
  }

  int get monthlyFuelings {
    return countBetween(
      selectedDate,
      DateTime(selectedYear, selectedMonth + 1),
    );
  }

  double get weeklySpent {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final monday = today.subtract(
      Duration(days: today.weekday - DateTime.monday),
    );

    return spentBetween(monday, monday.add(const Duration(days: 7)));
  }

  double get monthlyAverage {
    final dates = records
        .map((record) => parseDate(record['data']))
        .whereType<DateTime>()
        .toList();

    if (dates.isEmpty) return 0;

    dates.sort();

    final first = dates.first;
    final now = DateTime.now();

    final firstMonth = DateTime(first.year, first.month);
    final currentMonth = DateTime(now.year, now.month);

    if (firstMonth.isAfter(currentMonth)) return 0;

    final numberOfMonths =
        (now.year - first.year) * 12 + (now.month - first.month) + 1;

    final total = spentBetween(firstMonth, DateTime(now.year, now.month + 1));

    return total / numberOfMonths;
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result = await Future.wait([
        repository.listar('vehicles'),
        repository.listar('drivers'),
        repository.listar('fuelings'),
      ]);

      if (!mounted) return;

      setState(() {
        vehicles = result[0].length;
        drivers = result[1].length;
        records = result[2];
        fuelings = records.length;
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

  Future<void> logout() async {
    try {
      await AuthServiceLaravel().signOut();
    } catch (_) {}

    if (mounted) {
      context.goNamed(AppRoutes.signIn);
    }
  }

  Widget financial(String label, String amount, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.all(18),
          leading: CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.primaryLight,
            child: Icon(icon, color: AppColors.primaryDark),
          ),
          title: Text(label),
          trailing: Text(
            amount,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
        ),
      ),
    );
  }

  Widget summary(String label, int count, IconData icon, VoidCallback tap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: ListTile(
          onTap: tap,
          contentPadding: const EdgeInsets.all(18),
          leading: CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.primaryLight,
            child: Icon(icon, color: AppColors.primaryDark),
          ),
          title: Text(label),
          trailing: Text(
            '$count',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
        ),
      ),
    );
  }

  Widget monthFilter() {
    final now = DateTime.now();

    final years = <int>{
      now.year,
      selectedYear,
      ...records
          .map((record) => parseDate(record['data']))
          .whereType<DateTime>()
          .map((date) => date.year),
    }.toList()..sort((a, b) => b.compareTo(a));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Icon(Icons.filter_alt_outlined, color: AppColors.primaryDark),
            const Text(
              'Período:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButton<int>(
              value: selectedMonth,
              items: List.generate(12, (index) {
                return DropdownMenuItem<int>(
                  value: index + 1,
                  child: Text(monthNames[index]),
                );
              }),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedMonth = value);
                }
              },
            ),
            DropdownButton<int>(
              value: selectedYear,
              items: years.map((year) {
                return DropdownMenuItem<int>(value: year, child: Text('$year'));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedYear = value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel da Frota'),
        actions: [
          IconButton(
            onPressed: load,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: RefreshIndicator(
            onRefresh: load,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.local_shipping_rounded,
                        size: 54,
                        color: Colors.white,
                      ),
                      SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Controle de Frota',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Visão geral da sua operação',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Resumo',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),

                const SizedBox(height: 14),

                if (loading)
                  const Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (error != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(error!),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: load,
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  monthFilter(),

                  const SizedBox(height: 12),

                  financial(
                    'Gasto no mês',
                    currency(monthlySpent),
                    Icons.payments_outlined,
                  ),

                  financial(
                    'Gasto na semana',
                    currency(weeklySpent),
                    Icons.date_range_outlined,
                  ),

                  financial(
                    'Média mensal',
                    currency(monthlyAverage),
                    Icons.bar_chart_rounded,
                  ),

                  financial(
                    'Abastecimentos no mês',
                    '$monthlyFuelings',
                    Icons.local_gas_station_outlined,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Resumo da frota',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),

                  const SizedBox(height: 14),

                  summary(
                    'Veículos cadastrados',
                    vehicles,
                    Icons.local_shipping_rounded,
                    () => context.goNamed(AppRoutes.vehicles),
                  ),

                  summary(
                    'Motoristas cadastrados',
                    drivers,
                    Icons.people_rounded,
                    () => context.goNamed(AppRoutes.drivers),
                  ),

                  summary(
                    'Abastecimentos registrados',
                    fuelings,
                    Icons.local_gas_station_rounded,
                    () => context.goNamed(AppRoutes.fuelings),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
