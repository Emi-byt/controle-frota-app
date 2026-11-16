import 'package:flutter/material.dart';
import '../../widgets/frota_list_screen.dart';
import '../../widgets/frota_form_screen.dart';
class VehiclesScreen extends StatelessWidget {
 const VehiclesScreen({super.key});
 static const fields=[FrotaField('placa','Placa'),FrotaField('marca','Marca'),FrotaField('modelo','Modelo'),FrotaField('ano','Ano',number:true)];
 @override Widget build(BuildContext context)=>FrotaListScreen(title:'Veículos',resource:'vehicles',icon:Icons.local_shipping_rounded,
   itemTitle:(v)=>'${v['placa']??'Sem placa'} — ${v['modelo']??''}',itemSubtitle:(v)=>'${v['marca']??''} • Ano ${v['ano']??''}',
   onCreate:(c)=>Navigator.of(c,rootNavigator:true).push<bool>(MaterialPageRoute(builder:(_)=>const FrotaFormScreen(title:'Cadastrar veículo',resource:'vehicles',fields:fields))),
   onEdit:(c,v)=>Navigator.of(c,rootNavigator:true).push<bool>(MaterialPageRoute(builder:(_)=>FrotaFormScreen(title:'Editar veículo',resource:'vehicles',fields:fields,existing:v))));
}
