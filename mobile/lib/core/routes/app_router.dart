import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/auth/sign_in_screen.dart'; //login
import '../../screens/auth/sign_up_screen.dart';
import '../../screens/home/home_screen.dart'; //inicio
import '../../screens/shell/app_shell.dart'; //navegação
import '../../screens/vehicles/vehicles_screen.dart'; //veiculos
import '../../screens/vehicles/vehicle_form_screen.dart'; //cadastro do veículo
import '../../screens/drivers/drivers_screen.dart'; //motoristas
import '../../screens/fuelings/fuelings_screen.dart'; //abastecimentos
import 'app_routes.dart';

/// Gerencia a navegação do aplicativo Controle de Frota.
abstract final class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.signInPath,
    debugLogDiagnostics: true,

    routes: <RouteBase>[
      // 1. AUTENTICAÇÃO
      GoRoute(
        path: AppRoutes.signInPath,
        name: AppRoutes.signIn,
        builder: (context, state) => const SignInScreen(),
      ),

      GoRoute(
        path: AppRoutes.signUpPath,
        name: AppRoutes.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),

      // 2. NAVEGAÇÃO PRINCIPAL
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),

        branches: <StatefulShellBranch>[
          // ABA 1 - INÍCIO
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.homePath,
                name: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // ABA 2 - VEÍCULOS
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.vehiclesPath,
                name: AppRoutes.vehicles,
                builder: (context, state) => const VehiclesScreen(),

                routes: <RouteBase>[
                  // Cadastro de um novo veículo
                  GoRoute(
                    path: 'novo',
                    name: 'vehicleForm',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const VehicleFormScreen(),
                  ),
                ],
              ),
            ],
          ),

          // ABA 3 - ABASTECIMENTOS
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.fuelingsPath,
                name: AppRoutes.fuelings,
                builder: (context, state) => const FuelingsScreen(),
              ),
            ],
          ),

          // ABA 4 - MOTORISTAS
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.driversPath,
                name: AppRoutes.drivers,
                builder: (context, state) => const DriversScreen(),
              ),
            ],
          ),
        ],
      ),
    ],

    // Tela exibida quando o endereço não existe
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Rota não encontrada:\n${state.uri}',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
}
