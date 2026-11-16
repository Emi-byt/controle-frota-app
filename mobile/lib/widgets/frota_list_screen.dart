import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/frota_api.dart';

class FrotaListScreen extends StatefulWidget {
  const FrotaListScreen({super.key, required this.title, required this.resource,
    required this.icon, required this.itemTitle, required this.itemSubtitle,
    required this.onCreate, required this.onEdit});
  final String title,resource;
  final IconData icon;
  final String Function(Map<String,dynamic>) itemTitle;
  final String Function(Map<String,dynamic>) itemSubtitle;
  final Future<bool?> Function(BuildContext) onCreate;
  final Future<bool?> Function(BuildContext,Map<String,dynamic>) onEdit;
  @override State<FrotaListScreen> createState()=>_FrotaListScreenState();
}
class _FrotaListScreenState extends State<FrotaListScreen> {
  bool loading=true; String? error; List<Map<String,dynamic>> items=[];
  @override void initState(){super.initState();refresh();}
  Future<void> refresh() async {
    setState((){loading=true;error=null;});
    try {final values=await FrotaApi.list(widget.resource);
      if(mounted)setState((){items=values;loading=false;});
    } catch(e){if(mounted)setState((){error=e.toString().replaceFirst('Exception: ','');loading=false;});}
  }
  Future<void> remove(Map<String,dynamic> item) async {
    final confirmed=await showDialog<bool>(context:context,builder:(context)=>AlertDialog(
      title:const Text('Excluir registro?'),content:const Text('Esta ação não poderá ser desfeita.'),
      actions:[TextButton(onPressed:()=>Navigator.pop(context,false),child:const Text('Cancelar')),
        TextButton(onPressed:()=>Navigator.pop(context,true),child:const Text('Excluir'))]));
    if(confirmed!=true)return;
    try {await FrotaApi.delete(widget.resource,(item['id'] as num).toInt());await refresh();}
    catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('$e')));}
  }
  Future<void> create() async {final changed=await widget.onCreate(context);if(changed==true)await refresh();}
  Future<void> edit(Map<String,dynamic> item) async {final changed=await widget.onEdit(context,item);if(changed==true)await refresh();}
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:Text(widget.title),actions:[IconButton(tooltip:'Atualizar',onPressed:refresh,icon:const Icon(Icons.refresh_rounded))]),
    floatingActionButton:FloatingActionButton.extended(onPressed:create,icon:const Icon(Icons.add),label:const Text('Novo cadastro')),
    body:Center(child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:980),child:
      RefreshIndicator(onRefresh:refresh,child:ListView(padding:const EdgeInsets.all(20),children:[
        Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(color:AppColors.primaryDark,borderRadius:BorderRadius.circular(18)),
          child:Row(children:[Icon(widget.icon,color:Colors.white,size:36),const SizedBox(width:18),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text(widget.title,style:const TextStyle(color:Colors.white,fontSize:23,fontWeight:FontWeight.bold)),
            Text('${items.length} registros',style:const TextStyle(color:Colors.white70))]))])),
        const SizedBox(height:20),
        if(loading)const Padding(padding:EdgeInsets.all(36),child:Center(child:CircularProgressIndicator()))
        else if(error!=null)Card(child:Padding(padding:const EdgeInsets.all(24),child:Column(children:[Text(error!,textAlign:TextAlign.center),
          const SizedBox(height:12),OutlinedButton(onPressed:refresh,child:const Text('Tentar novamente'))])))
        else if(items.isEmpty)Card(child:Padding(padding:const EdgeInsets.all(36),child:Column(children:[Icon(widget.icon,size:48,color:AppColors.primary),const SizedBox(height:12),
          const Text('Nenhum registro encontrado'),const SizedBox(height:10),OutlinedButton(onPressed:create,child:const Text('Cadastrar agora'))])))
        else ...items.map((item)=>Padding(padding:const EdgeInsets.only(bottom:10),child:Card(child:ListTile(
          contentPadding:const EdgeInsets.symmetric(horizontal:18,vertical:8),leading:CircleAvatar(backgroundColor:AppColors.primaryLight,child:Icon(widget.icon,color:AppColors.primaryDark)),
          title:Text(widget.itemTitle(item),style:const TextStyle(fontWeight:FontWeight.w700)),subtitle:Text(widget.itemSubtitle(item)),
          trailing:Wrap(spacing:0,children:[IconButton(tooltip:'Editar',onPressed:()=>edit(item),icon:const Icon(Icons.edit_outlined)),
            IconButton(tooltip:'Excluir',onPressed:()=>remove(item),icon:const Icon(Icons.delete_outline,color:AppColors.danger))]) )))),
        const SizedBox(height:80),
      ])))));
}
