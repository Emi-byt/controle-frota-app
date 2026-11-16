import 'package:flutter/material.dart';
import '../../widgets/frota_list_screen.dart';
import '../../widgets/frota_form_screen.dart';
class DriversScreen extends StatelessWidget {
 const DriversScreen({super.key});
 static const fields=[FrotaField('nome','Nome'),FrotaField('cpf','CPF'),FrotaField('cnh','CNH'),FrotaField('telefone','Telefone',optional:true)];
 @override Widget build(BuildContext context)=>FrotaListScreen(title:'Motoristas',resource:'drivers',icon:Icons.badge_outlined,
   itemTitle:(v)=>'${v['nome']??'Sem nome'}',itemSubtitle:(v)=>'CNH: ${v['cnh']??''} • CPF: ${v['cpf']??''}',
   onCreate:(c)=>Navigator.of(c,rootNavigator:true).push<bool>(MaterialPageRoute(builder:(_)=>const FrotaFormScreen(title:'Cadastrar motorista',resource:'drivers',fields:fields))),
   onEdit:(c,v)=>Navigator.of(c,rootNavigator:true).push<bool>(MaterialPageRoute(builder:(_)=>FrotaFormScreen(title:'Editar motorista',resource:'drivers',fields:fields,existing:v))));
}
