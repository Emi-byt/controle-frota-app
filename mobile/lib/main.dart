import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';

/// Ponto de entrada do aplicativo Controle de Frota.
///
/// Prepara os recursos necessários antes de abrir a primeira tela.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa a formatação de datas em português.
  await initializeDateFormatting('pt_BR');

  // Inicia o aplicativo.
  runApp(const ControleFrotaApp());
}
