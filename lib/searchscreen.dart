
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchScreen extends StatefulWidget {
  
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _textEditingController = new TextEditingController();
  String applicationId ='b702e461';
  String applicationKey= '1bdbca0d4344e3db6103b072c21f38f1';
  getRecipes(String query)async{
    final urldet= "https://api.edamam.com/api/recipes/v2/0ec48df32629a4349a37af0fed9a6835?type=public&app_id=b702e461&app_key=1bdbca0d4344e3db6103b072c21f38f1";
    //0ec48df32629a4349a37af0fed9a6835 id 
    final url = Uri.parse("https://api.edamam.com/api/recipes/v2?type=public&q=$query&app_id=$applicationId&app_key=$applicationKey");
    //final url = Uri.parse(cadena);
    var response = await http.get(url);
    String cadena="http://www.edamam.com/ontologies/edamam.owl#recipe_0ec48df32629a4349a37af0fed9a6835";
    String subcadena;
    subcadena=cadena.replaceAll("http://www.edamam.com/ontologies/edamam.owl#recipe_",'');
    print(subcadena);
    print ("${response.body.toString()} this is response");
    

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('AppName'),
          flexibleSpace: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
            Color(0xff213A50),
            Color(0xff071930),
          ]))),
          actions: [
            IconButton(
              onPressed: () => {},
              icon: Icon(Icons.account_circle_rounded),
              iconSize: 30.0,
            )
          ],
        ),
        
        body: Stack(
          
          children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              Color(0xff213A50),
              Color(0xff071930),
            ])),
          ),
          Container(
              padding: EdgeInsets.symmetric(vertical: 30, horizontal: 30),
              
              child: Column(
                children: <Widget>[
                  Row(
                    
                    children: <Widget>[
                      Text(
                        "WELCOME USER",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
      
                    children: <Widget>[
                      Text(
                        "What do want to cook today?",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                      child:Text(
                        "Enter ingredients you have and we will show the best recipies for you",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          
                        ),
                      ),
                  )
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: <Widget>[
                      Expanded(
                      child:TextField(
                          controller: _textEditingController,
                          decoration: InputDecoration(
                            hintText: "Enter Ingridients",
                            hintStyle: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            )
                          ),
                          style: TextStyle(
                            fontSize: 18
                          )
                        ),
                    ),
                    SizedBox(width: 16,),
                    InkWell(
                      onTap: (){
                          Text("data");
                       if (_textEditingController.text.isNotEmpty) {
                         
                         getRecipes(_textEditingController.text);
                       }
                      },
                      child: Container(
                        child: Icon(Icons.search, color: Colors.white,size: 50.0),
                        
                      ),
                    )
                      ],
                    ),
                  )
                ],
              )
          )
        ]));
  }
}
