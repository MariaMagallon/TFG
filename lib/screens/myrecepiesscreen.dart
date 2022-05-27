import 'dart:convert';
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:tfg/models/own_recipe.dart';
import 'package:tfg/models/recipe.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:tfg/models/recipe_detail.dart';
import 'package:http/http.dart' as http;
import 'package:tfg/screens/createrecipescreen.dart';
import 'package:tfg/screens/detailscreenunified.dart';
import 'package:tfg/widgets/navigation_drawer_widget.dart';

final db = FirebaseFirestore.instance;

class MyRecipes extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser!;

  MyRecipes({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('AppName'),
            flexibleSpace: Container(
                decoration: const BoxDecoration(color: Colors.indigo)),
            actions: [
              Builder(builder: (context) {
                return IconButton(
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                  icon: const Icon(Icons.account_circle_rounded),
                  iconSize: 30.0,
                );
              }),
            ],
            leading: IconButton(
              onPressed: () => {
                Navigator.pop(context),
              },
              icon: const Icon(Icons.arrow_back_sharp),
              iconSize: 30.0,
            )),
        endDrawer: const NavigationDrawerWidget(),
        body: Center(
            child: Column(
          children: <Widget>[
            const SizedBox(
              height: 30,
            ),
            const Center(
              child: Text(
                ('My Recipes'),
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const CreateRecipeScreen(),
                  ));
                },
                child: const Text(
                  'Create a new recipe',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  onPrimary: Colors.white,
                  primary: Colors.indigo,
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            _RecipesAPI(),
            _RecipesUser(),
          ],
        )));
  }
}

class _RecipesAPI extends StatelessWidget {
  _RecipesAPI({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: loadRecipes(1),
      builder: (BuildContext context, AsyncSnapshot<List<Recipe>> snapshot) {
        if (snapshot.hasError) {
          return ErrorWidget(snapshot.error.toString());
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final _listrecipesAPI = snapshot.data!;

        return GridView(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            physics: const ClampingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200, mainAxisSpacing: 10.0),
            children: List.generate(_listrecipesAPI.length, (index) {
              return GridTile(
                  child: GestureDetector(
                      onTap: () {
                        String idRecipe;
                        idRecipe = _listrecipesAPI[index].idapi!;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return DetailScreen(
                                api: true,
                                pidRecipe: idRecipe,
                              );
                            },
                          ),
                        );
                      },
                      child: RecipeTile(
                          id: _listrecipesAPI[index].idapi!,
                          imageurl: _listrecipesAPI[index].image,
                          title: _listrecipesAPI[index].label)));
            }));
      },
    );
  }
}

class RecipeTile extends StatefulWidget {
  String title, imageurl, id;

  RecipeTile(
      {Key? key, required this.id, required this.title, required this.imageurl})
      : super(key: key);

  @override
  _RecipeTileState createState() => _RecipeTileState();
}

class _RecipeTileState extends State<RecipeTile> {
  Recipe recipeDetail = Recipe(
      label: "label",
      image: "image",
      uri: "uri",
      url: "url",
      calories: 0.0,
      ingredientLines: [],
      dishType: [],
      healthLabels: [],
      cuisineType: []);

  Future<Recipe> getRecipe(String idrecipe) async {
    String applicationId = 'b702e461';
    String applicationKey = '1bdbca0d4344e3db6103b072c21f38f1';

    final url = Uri.parse(
        "https://api.edamam.com/api/recipes/v2/$idrecipe?type=public&app_id=$applicationId&app_key=$applicationKey");

    var response = await http.get(url);

    //print(response);

    Map<String, dynamic> jsonData = jsonDecode(response.body);

    recipeDetail = Recipe.fromMap(jsonData["recipe"]);
    //print(recipeDetail.label);

    return recipeDetail;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getRecipe(widget.id),
        builder: (context, AsyncSnapshot<Recipe> snapshot) {
          if (snapshot.hasError) {
            return ErrorWidget(snapshot.error.toString());
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          recipeDetail = snapshot.data!;
          widget.imageurl = recipeDetail.image;
          return Container(
            margin: const EdgeInsets.all(8),
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
                  decoration:
                      BoxDecoration(color: Colors.white.withOpacity(0.5)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.title,
                          style: const TextStyle(
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
        });
  }
}

class _RecipesUser extends StatelessWidget {
  _RecipesUser({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: loadRecipes(0),
      builder: (BuildContext context, AsyncSnapshot<List<Recipe>> snapshot) {
        if (snapshot.hasError) {
          return ErrorWidget(snapshot.error.toString());
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final _listrecipesUser = snapshot.data!;

        return GridView(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            physics: const ClampingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200, mainAxisSpacing: 10.0),
            children: List.generate(_listrecipesUser.length, (index) {
              return GridTile(
                  child: GestureDetector(
                      onTap: () {
                        String idRecipe;
                        idRecipe = _listrecipesUser[index].id!;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return DetailScreen(
                                api: false,
                                pidRecipe: idRecipe,
                              );
                            },
                          ),
                        );
                      },
                      child: RecipeTileUser(
                          imageurl: _listrecipesUser[index].image,
                          title: _listrecipesUser[index].label)));
            }));
      },
    );
  }
}

class RecipeTileUser extends StatefulWidget {
  final String title, imageurl;

  const RecipeTileUser({Key? key, required this.title, required this.imageurl})
      : super(key: key);

  @override
  _RecipeTileUserState createState() => _RecipeTileUserState();
}

class _RecipeTileUserState extends State<RecipeTileUser> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
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
                    style: const TextStyle(
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
}
