import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/frota_api.dart';

class FrotaFormScreen extends StatefulWidget {
  const FrotaFormScreen({super.key,required this.title,required this.resource,required this.fields,this.existing});
  final String title,resource;
  final List<FrotaField> fields;
  final Map<String,dynamic>? existing;
  @override State<FrotaFormScreen> createState()=>_FrotaFormScreenState();
}
class FrotaField {
  const FrotaField(this.key,this.label,{this.number=false,this.optional=false,this.date=false});
  final String key,label;final bool number,optional,date;
}
class _FrotaFormScreenState extends State<FrotaFormScreen> {
  final key=GlobalKey<FormState>();late final Map<String,TextEditingController> controllers;
  bool saving=false;
  @override void initState(){super.initState();controllers={for(final field in widget.fields)field.key:TextEditingController(text:'${widget.existing?[field.key] ?? ''}')};}
  @override void dispose(){for(final c in controllers.values)c.dispose();super.dispose();}
  Future<void> save() async {
    if(!key.currentState!.validate())return;
    setState(()=>saving=true);
    try {
      final data=<String,dynamic>{};
      for(final field in widget.fields){final value=controllers[field.key]!.text.trim();
        data[field.key]=value.isEmpty && field.optional ? null : field.number ? num.parse(value.replaceAll(',','.')) : value;}
      final id=widget.existing?['id'];
      await FrotaApi.save(widget.resource,data,id:id is num?id.toInt():null);
      if(!mounted)return;
      Navigator.of(context).pop(true);
    }catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('$e')));}
    finally{if(mounted)setState(()=>saving=false);}
  }
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:Text(widget.title)),
    body:Center(child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:620),child:
      SingleChildScrollView(padding:const EdgeInsets.all(20),child:Card(child:Padding(padding:const EdgeInsets.all(24),child:
        Form(key:key,child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
          const Icon(Icons.local_shipping_rounded,size:48,color:AppColors.primaryDark),const SizedBox(height:20),
          ...widget.fields.map((field)=>Padding(padding:const EdgeInsets.only(bottom:16),child:TextFormField(
            controller:controllers[field.key],keyboardType:field.number?const TextInputType.numberWithOptions(decimal:true):TextInputType.text,
            decoration:InputDecoration(labelText:field.label,helperText:field.date?'Formato: AAAA-MM-DD':null),
            validator:(value){final text=value?.trim()??'';
              if(text.isEmpty && !field.optional)return 'Preencha ${field.label.toLowerCase()}';
              if(text.isNotEmpty && field.number && num.tryParse(text.replaceAll(',','.'))==null)return 'Informe um número válido';
              if(field.date && text.isNotEmpty && !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text))return 'Use AAAA-MM-DD';
              return null;}))),
          const SizedBox(height:8),ElevatedButton.icon(onPressed:saving?null:save,
            icon:saving?const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2)):const Icon(Icons.save_outlined),
            label:Text(saving?'Salvando...':'Salvar')),
        ]))))))));
}
