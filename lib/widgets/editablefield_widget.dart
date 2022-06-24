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
  bool type=true;

  
  @override
  void initState() {
    super.initState();
    
    controller = TextEditingController(text: widget.value);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Center(child: Text(widget.title.toUpperCase(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),)),
        content: 
        Container(
        child: (!oscuro)?
        Row(
          children: [
            SizedBox(
              width: 230,
              child: TextField(
                obscureText: oscuro,
                controller: controller,
                decoration: const InputDecoration(
                 border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.all(Radius.circular(10.0)),
                  borderSide:
                      BorderSide(color: Colors.grey, width: 0.0),
                ),
                ),
                keyboardType: textoTipo,
              ),
            ),

          ],
        ):Row(
                children: [
                  SizedBox(
                    width: 230,
                    child: TextField(
                      controller: controller,
                      obscureText: type,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(color: Colors.grey, width: 0.0),
                          ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        type=!type;
                      });
                    },
                    icon: const Icon(Icons.remove_red_eye),
                    iconSize: 20.0,
                  )
                ],
              ),
        ),
        actions: [
          Center(
          child: ElevatedButton(
              child: const Text(
              'Done', 
              style: TextStyle( 
                fontSize: 19,
                color: Colors.white,
                fontFamily: "Heebo",
                fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
            onPrimary: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            primary: Colors.teal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)),
            ),
              onPressed: () => Navigator.of(context).pop(controller.text),
            ),
          ),
          const SizedBox(
            height: 10,
          )
        ],
        
      );
}