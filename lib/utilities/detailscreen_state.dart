/*import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tfg/models/recipe_api.dart';
import 'package:tfg/models/recipe_detail.dart';*/

/*class DetailScreen extends StatefulWidget {
  const DetailScreen({Key? key}) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  RecipeDetail recipeDetail =
      RecipeDetail(label: "label", image: "image", uri: "uri");
  bool isloading = false;

  String applicationId = 'b702e461';
  String applicationKey = '1bdbca0d4344e3db6103b072c21f38f1';

  getRecipe() async {
    final url = Uri.parse(
        "https://api.edamam.com/api/recipes/v2/0ec48df32629a4349a37af0fed9a6835?type=public&app_id=$applicationId&app_key=$applicationKey");

    var response = await http.get(url);

    print(response);

    Map<String, dynamic> jsonData = jsonDecode(response.body);

    recipeDetail = RecipeDetail.fromMap(jsonData["recipe"]);
    print(recipeDetail.label);
    print(recipeDetail.label);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('AppName'),
          flexibleSpace:
              Container(decoration: BoxDecoration(color: Colors.indigo)),
          actions: [
            IconButton(
              onPressed: () => {},
              icon: Icon(Icons.account_circle_rounded),
              iconSize: 30.0,
            )
          ],
        ),
        body: Stack(children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(color: Colors.indigo),
          ),
          SingleChildScrollView(
            child: Container(
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
                          child: Text(
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
                          SizedBox(
                            width: 16,
                          ),
                            
                          /*FloatingActionButton.extended(
                            onPressed: () {
                              setState(() {
                                isloading = true;
                              });
                              getRecipe();
                              setState(() {
                                isloading = false;
                              });
                            },
                            label: const Text('Torna al principi'),
                            icon: const Icon(Icons.home),
                            backgroundColor: Colors.black,
                          ),*/
                        ],
                      ),
                    ),
                    SizedBox(height: 25),
                    Container(
                        child: isloading
                            ? CircularProgressIndicator()
                            : Text(recipeDetail.label))
                  ],
                )),
          )
        ]));
  }
}

class RecipeTile extends StatefulWidget {
  final String title, imageurl;

  RecipeTile({required this.title, required this.imageurl});

  @override
  _RecipeTileState createState() => _RecipeTileState();
}

class _RecipeTileState extends State<RecipeTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      child: Stack(
        children: <Widget>[
          Image.network(
            widget.imageurl,
            height: 200,
            width: 200,
            fit: BoxFit.cover,
          ),
          Container(
            width: 200,
            alignment: Alignment.bottomLeft,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.5)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.title,
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}*/
