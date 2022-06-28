import 'dart:convert';
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cookmind/models/recipe.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cookmind/screens/createmodifyrecipescreen.dart';
import 'package:cookmind/screens/detailscreen.dart';
import 'package:cookmind/widgets/navigation_drawer_widget.dart';
import 'package:cookmind/globals/apikeys.dart';

final db = FirebaseFirestore.instance;

class MyRecipes extends StatelessWidget {

  Recipe emptyrecipe = Recipe(
      label: "",
      image: "",
      uri: "",
      url: "",
      calories: 0.0,
      ingredientLines: [],
      dishType: [],
      healthLabels: [],
      cuisineType: []);

  MyRecipes({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
              flexibleSpace: Container(
                decoration: const BoxDecoration(color: Colors.teal)),
              title: Center(child: Image.asset("assets/logo.png", filterQuality:FilterQuality.high,)),
              actions: [
                Builder(builder: (context) {
                  return IconButton(
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                    icon: const Icon(Icons.account_circle_rounded),
                    iconSize: 40.0,
                    color: Colors.white,
                  );
                }),
              ],
              leading: IconButton(
              onPressed: () => {
                Navigator.of(context).pop(),
              },
              icon: const Icon(Icons.arrow_back_sharp),
              iconSize: 40.0,
            ),
          ),
        endDrawer: const NavigationDrawerWidget(),
        body: SingleChildScrollView(
          child: Center(
              child: Column(
            children: <Widget>[
              const SizedBox(
                height: 20,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text(
                      "My Recipes",
                      style: TextStyle(
                          fontSize: 25,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.restaurant_menu,
                        color: Colors.teal, size: 30.0),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  width: 2, color: Colors.amber))),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => CreateModifyRecipeScreen(
                          precipe: emptyrecipe, iscreating: true),
                    ));
                  },
                  
                child: const Text(
                    'Create a new recipe',
                      style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontFamily: "Heebo",
                          fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    onPrimary: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    primary: Colors.teal,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: _RecipesAPI(),
              ),
              const Padding(
                padding: EdgeInsets.only(left:20.0, right: 20.0),
                child: _RecipesUser(),
              ),
            ],
          )),
        ));
  }
}

class _RecipesAPI extends StatelessWidget {
  const _RecipesAPI({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: loadRecipes(true),
      builder: (BuildContext context, AsyncSnapshot<List<Recipe>> snapshot) {
        if (snapshot.hasError) {
          return ErrorWidget(snapshot.error.toString());
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Colors.teal,));
        }
        final _listrecipesAPI = snapshot.data!;

        return GridView.count(
             crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            physics: const ClampingScrollPhysics(),
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
                                origen: 1,
                                pidRecipe: idRecipe,
                                recipeDetail: _listrecipesAPI[index],
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



  Future<Recipe> getRecipeFromAPI(String idrecipe) async {
    

    final url = Uri.parse(
        "https://api.edamam.com/api/recipes/v2/$idrecipe?type=public&app_id=$applicationId&app_key=$applicationKey");

    var response = await http.get(url);

    

    Map<String, dynamic> jsonData = jsonDecode(response.body);

    recipeDetail = Recipe.fromMap(jsonData["recipe"]);
    

    return recipeDetail;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder (
        future: getRecipeFromAPI(widget.id),
        builder: (context, AsyncSnapshot<Recipe> snapshot) {
          if (snapshot.hasError) {
            return ErrorWidget(snapshot.error.toString());
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Colors.teal,));
          }
          recipeDetail = snapshot.data!;
          widget.imageurl = recipeDetail.image;
          return Card(
            color: Colors.transparent,
            elevation: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: NetworkImage(widget.imageurl),
                  fit: BoxFit.cover
                ),
                
              ),
              child: Transform.translate(
                offset: const Offset(0, 50),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 50),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white.withOpacity(0.5)
                  ),
                  child: Text(
                    widget.title.toUpperCase(), 
                    style: const TextStyle( 
                      fontSize: 15,
                      color: Colors.black,
                      fontFamily: "Heebo",
                      overflow: TextOverflow.clip,
                      fontWeight: FontWeight.bold)),
                ),
              ),
              
                
              
            ),
          );
        });
  }
}

class _RecipesUser extends StatelessWidget {
  const _RecipesUser({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: loadRecipes(false),
      builder: (BuildContext context, AsyncSnapshot<List<Recipe>> snapshot) {
        if (snapshot.hasError) {
          return ErrorWidget(snapshot.error.toString());
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Colors.teal,));
        }
        final _listrecipesUser = snapshot.data!;

        return GridView.count(
             crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            physics: const ClampingScrollPhysics(),
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
                                origen: 2,
                                pidRecipe: idRecipe,
                                recipeDetail: _listrecipesUser[index],
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
    return 
          (widget.imageurl != "")?
          Card(
            color: Colors.transparent,
            elevation: 0,
            
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: NetworkImage(widget.imageurl),
                  fit: BoxFit.cover
            ),
                
              ),
              child: Transform.translate(
                offset: const Offset(0, 50),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 50),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white.withOpacity(0.5)
                  ),
                  child: Text(
                    widget.title.toUpperCase(), 
                    style: const TextStyle( 
                      fontSize: 15,
                      color: Colors.black,
                      fontFamily: "Heebo",
                      overflow: TextOverflow.clip,
                      fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ):Card(
            color: Colors.transparent,
            elevation: 0,
            
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.teal,
                
              ),
              child: Transform.translate(
                offset: const Offset(0, 50),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 50),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white.withOpacity(0.5)
                  ),
                  child: Text(
                    widget.title.toUpperCase(), 
                    style: const TextStyle( 
                      fontSize: 15,
                      color: Colors.black,
                      fontFamily: "Heebo",
                      overflow: TextOverflow.clip,
                      fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          );
  }
}
