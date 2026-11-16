import 'package:flutter/material.dart';

import 'core/constants/app_strings.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';

/// Widget raiz do Controle de Frota.
///
/// Configura o tema, as rotas e o título do aplicativo.
class ControleFrotaApp extends StatelessWidget {
  const ControleFrotaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
    );
  }
}
