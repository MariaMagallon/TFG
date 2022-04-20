import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:tfg/models/recipe_api.dart';
import 'package:tfg/screens/detailscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tfg/widgets/navigation_drawer_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool isloading = false;
  final user = FirebaseAuth.instance.currentUser!;
  List<RecipeApi> recipes = [];
  final TextEditingController _textEditingController = TextEditingController();
  String applicationId = 'b702e461';
  String applicationKey = '1bdbca0d4344e3db6103b072c21f38f1';

  getRecipes(String query) async {
    //final urldet ="https://api.edamam.com/api/recipes/v2/0ec48df32629a4349a37af0fed9a6835?type=public&app_id=b702e461&app_key=1bdbca0d4344e3db6103b072c21f38f1";
    //0ec48df32629a4349a37af0fed9a6835 id
    final url = Uri.parse(
        "https://api.edamam.com/api/recipes/v2?type=public&q=$query&app_id=$applicationId&app_key=$applicationKey");
    //final url = Uri.parse(cadena);
    var response = await http.get(url);
    //String cadena = "http://www.edamam.com/ontologies/edamam.owl#recipe_0ec48df32629a4349a37af0fed9a6835";
    //String subcadena;
    //subcadena = cadena.replaceAll( "http://www.edamam.com/ontologies/edamam.owl#recipe_", '');
    //print(subcadena);
    //print ("${response.body.toString()} this is response");
    recipes.clear();
    Map<String, dynamic> jsonData = jsonDecode(response.body);
    jsonData["hits"].forEach((element) {
      RecipeApi recipeApi =
          RecipeApi(label: "label", image: "image", uri: "uri");
      recipeApi = RecipeApi.fromMap(element["recipe"]);
      recipes.add(recipeApi);
    });
    //print("${recipes.toString()}");
  }

  @override
  void initState() {
    super.initState();
    isloading = false;
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
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                    icon: const Icon(Icons.account_circle_rounded),
                    iconSize: 30.0,
                  );
                }),
              ],
              /*actions: [
                IconButton(
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  icon: const Icon(Icons.account_circle_rounded),
                  iconSize: 30.0,
                ),
              ],*/
              /*leading: IconButton(
                onPressed: () => Navigator.of(context).pop(context),
                icon: const Icon(Icons.arrow_back_sharp),
                iconSize: 30.0,
              ),*/
            ),
            endDrawer: const NavigationDrawerWidget(),
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
                              user.email!,
                              style: const TextStyle(
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
                                onTap: () {
                                  if (_textEditingController.text.isNotEmpty) {
                                    setState(() {
                                      isloading = true;
                                    });
                                    getRecipes(_textEditingController.text);
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
                              ? const CircularProgressIndicator()
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
                                              //print("${recipes[index].label}");
                                              //print("${recipes[index].uri}");
                                              String idRecipe;
                                              idRecipe = recipes[index]
                                                  .uri
                                                  .replaceAll(
                                                      "http://www.edamam.com/ontologies/edamam.owl#recipe_",
                                                      '');
                                              //print("https://api.edamam.com/api/recipes/v2/$idRecipe?type=public&app_id=b702e461&app_key=1bdbca0d4344e3db6103b072c21f38f1");
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) {
                                                    return DetailScreen(
                                                      pidRecipe: idRecipe,
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