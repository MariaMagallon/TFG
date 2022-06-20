import 'package:flutter/material.dart';
  
var textoTipo=TextInputType.text;
bool oscuro=false;
Future<T?> showTextDialog<T>(
  BuildContext context, {
  required String title,
  required String value,
  required var tipoteclado,
  required bool poscuro,  
}) {
  textoTipo=tipoteclado;
  oscuro=poscuro;
    return showDialog<T>(
      context: context,
      builder: (context) => TextDialogWidget(
        title: title,
        value: value,
        
       
      ),
    );
}
class TextDialogWidget extends StatefulWidget {
  final String title;
  final String value;
  
  

  const TextDialogWidget({
    Key? key,
    required this.title,
    required this.value,
   
  }) : super(key: key);

  @override
  _TextDialogWidgetState createState() => _TextDialogWidgetState();
}

class _TextDialogWidgetState extends State<TextDialogWidget> {
  late TextEditingController controller;

  
  @override
  void initState() {
    super.initState();
    
    controller = TextEditingController(text: widget.value);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(widget.title),
        content: 
        (!oscuro)?
        Row(
          children: [
            TextField(
              obscureText: oscuro,
              controller: controller,
              decoration: const InputDecoration(
              border: OutlineInputBorder(),
              ),
              keyboardType: textoTipo,
            ),

          ],
        ):Row(
                children: [
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: controller,
                      obscureText: oscuro,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        oscuro=!oscuro;
                      });
                    },
                    icon: const Icon(Icons.remove_red_eye),
                    iconSize: 20.0,
                  )
                ],
              ),
        
        actions: [
          ElevatedButton(
            child: const Text('Done'),
            onPressed: () => Navigator.of(context).pop(controller.text),
          )
        ],
      );
}