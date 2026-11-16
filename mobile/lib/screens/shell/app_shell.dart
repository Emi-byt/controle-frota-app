import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
class AppShell extends StatelessWidget {
 const AppShell({required this.navigationShell,super.key});
 final StatefulNavigationShell navigationShell;
 @override Widget build(BuildContext context)=>Scaffold(
  body:navigationShell,
  bottomNavigationBar:NavigationBar(
   backgroundColor:AppColors.surface,
   indicatorColor:AppColors.primaryLight,
   selectedIndex:navigationShell.currentIndex,
   onDestinationSelected:(index)=>navigationShell.goBranch(index,initialLocation:index==navigationShell.currentIndex),
   destinations:const [
    NavigationDestination(icon:Icon(Icons.dashboard_outlined),selectedIcon:Icon(Icons.dashboard),label:'Início'),
    NavigationDestination(icon:Icon(Icons.local_shipping_outlined),selectedIcon:Icon(Icons.local_shipping),label:'Veículos'),
    NavigationDestination(icon:Icon(Icons.local_gas_station_outlined),selectedIcon:Icon(Icons.local_gas_station),label:'Abastecimentos'),
    NavigationDestination(icon:Icon(Icons.people_outline),selectedIcon:Icon(Icons.people),label:'Motoristas'),
   ]));
}
