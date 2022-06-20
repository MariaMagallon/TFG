import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:tfg/models/recipe.dart';
import 'package:tfg/screens/detailscreenunified.dart';
import 'package:tfg/widgets/navigation_drawer_widget.dart';
import 'package:tfg/globals/apikeys.dart';
import 'package:tfg/globals/globalvariables.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool isloading = false;

  

  List<Recipe> recipes = [];
  final TextEditingController _textEditingController = TextEditingController();

  getRecipes(String query) async {
    final url = Uri.parse(
        "https://api.edamam.com/api/recipes/v2?type=public&q=$query&app_id=$applicationId&app_key=$applicationKey");
    var response = await http.get(url);
    recipes.clear();
    Map<String, dynamic> jsonData = jsonDecode(response.body);
    jsonData["hits"].forEach((element) {
      Recipe recipeApi = Recipe(
          label: "label",
          image: "image",
          uri: "uri",
          url: "url",
          calories: 0.0,
          ingredientLines: [],
          dishType: [],
          healthLabels: [],
          cuisineType: []);
      recipeApi = Recipe.fromMap(element["recipe"]);
      recipes.add(recipeApi);
    });
    
  }

  @override
  void initState() {
    super.initState();
    isloading = false;
    recipes.clear();
   if ((user.displayName)==null){
      user.displayName!="";
   }
    
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // Aquí es retorna cert o false segons si vols prevenir que es pugui tornar enrere
          return true;
        },
        child: Scaffold(
            appBar: AppBar(
              title: const Text('AppName'),
              flexibleSpace: Container(
                  decoration: const BoxDecoration(color: Colors.indigo)),
              actions: [
                Builder(builder: (context) {
                  return IconButton(
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                    icon: const Icon(Icons.account_circle_rounded),
                    iconSize: 30.0,
                  );
                }),
              ],
            ),
            endDrawer: const NavigationDrawerWidget(),
            onEndDrawerChanged: (val) {
              if (val) {
                setState(() {
                 
                });
              } else {
                setState(() {
                 
                });
              }
            },
            body: Stack(children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(color: Colors.indigo),
              ),
              SingleChildScrollView(
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 30, horizontal: 30),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              "Welcome "+user.email!,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            ((user.displayName)==null)?
                            Text(
                              user.displayName!,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ):
                            const Text(
                              "User",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Row(
                          children: const <Widget>[
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
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: const <Widget>[
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
                        const SizedBox(
                          height: 30,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: TextField(
                                    controller: _textEditingController,
                                    decoration: const InputDecoration(
                                        hintText: "Enter Ingridients",
                                        hintStyle: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                        )),
                                    style: const TextStyle(
                                        fontSize: 18, color: Colors.white)),
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                              InkWell(
                                onTap: () async {
                                  if (_textEditingController.text.isNotEmpty) {
                                    setState(() {
                                      isloading = true;
                                    });
                                    await getRecipes(
                                        _textEditingController.text);
                                    setState(() {
                                      isloading = false;
                                    });
                                  }
                                },
                                child: const Icon(Icons.search,
                                    color: Colors.white, size: 50.0),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        Container(
                          child: isloading
                              ? const CircularProgressIndicator(
                                  backgroundColor: Colors.white,
                                )
                              : GridView(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  physics: const ClampingScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: 200,
                                          mainAxisSpacing: 10.0),
                                  children:
                                      List.generate(recipes.length, (index) {
                                    return GridTile(
                                        child: GestureDetector(
                                            onTap: () {
                                              String idRecipe;
                                              idRecipe =
                                                  edamamId(recipes[index].uri);

                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) {
                                                    return DetailScreen(
                                                      origen: 0,
                                                      pidRecipe: idRecipe,
                                                      recipeDetail:
                                                          recipes[index],
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                            child: RecipeTile(
                                                imageurl: recipes[index].image,
                                                title: recipes[index].label)));
                                  }),
                                ),
                        )
                      ],
                    )),
              )
            ])));
  }
}

class RecipeTile extends StatefulWidget {
  final String title, imageurl;

  const RecipeTile({Key? key, required this.title, required this.imageurl})
      : super(key: key);

  @override
  _RecipeTileState createState() => _RecipeTileState();
}

class _RecipeTileState extends State<RecipeTile> {
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
