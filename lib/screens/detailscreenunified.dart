import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:tfg/models/recipe.dart';
import 'package:tfg/widgets/navigation_drawer_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final db = FirebaseFirestore.instance;

class DetailScreen extends StatelessWidget {
  String pidRecipe;
  bool api;

  DetailScreen({Key? key, required this.pidRecipe, required this.api})
      : super(key: key);

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
  bool isloading = false;
  final user = FirebaseAuth.instance.currentUser!;
  String applicationId = 'b702e461';
  String applicationKey = '1bdbca0d4344e3db6103b072c21f38f1';

  Future<Recipe> getRecipe(bool api) async {
    if (api) {
      final url = Uri.parse(
          "https://api.edamam.com/api/recipes/v2/$pidRecipe?type=public&app_id=$applicationId&app_key=$applicationKey");

      var response = await http.get(url);

      //print(response);

      Map<String, dynamic> jsonData = jsonDecode(response.body);

      recipeDetail = Recipe.fromMap(jsonData["recipe"]);
      return recipeDetail;
      //print(recipeDetail.label);
    } else {
      return getFirestoreRecipe(pidRecipe);
    }
    
  }

  void _launchURL() async {
    if (!await launch(recipeDetail.url)) {
      throw 'Could not launch' + recipeDetail.url;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
                  IconButton(
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                    icon: const Icon(Icons.account_circle_rounded),
                    iconSize: 30.0,
                  )
                ],
                leading: IconButton(
                  onPressed: () => {
                    Navigator.pop(context),
                  },
                  icon: const Icon(Icons.arrow_back_sharp),
                  iconSize: 30.0,
                )),
            endDrawer: const NavigationDrawerWidget(),
            body: FutureBuilder(
                future: getRecipe(api),
                builder: (context, AsyncSnapshot<Recipe> snapshot) {
                  if (snapshot.hasError) {
                    return ErrorWidget(snapshot.error.toString());
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  recipeDetail = snapshot.data!;

                  return Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Stack(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topCenter,
                          child: Image.network(
                            recipeDetail.image,
                            fit: BoxFit.cover,
                            height: size.height * 0.55,
                          ),
                        ),
                        DraggableScrollableSheet(
                          maxChildSize: 1,
                          initialChildSize: 0.6,
                          minChildSize: 0.6,
                          builder: (context, controller) {
                            return SingleChildScrollView(
                              controller: controller,
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                height: 1000,
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(50),
                                      topRight: Radius.circular(50),
                                    )),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                            height: 5,
                                            width: 40,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                    color: Colors.grey))),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Text(
                                          recipeDetail.label,
                                          style: const TextStyle(
                                              fontSize: 19,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          onPressed: () async {
                                            recipeDetail.idapi =
                                                edamamId(recipeDetail.uri);
                                            recipeDetail.isapi = 1;
                                            await createRecipe(recipeDetail);
                                          },
                                          color: Colors.redAccent,
                                          icon: const Icon(Icons.favorite),
                                          iconSize: 30,
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  border: Border.all(
                                                      color: Colors.grey
                                                          .withOpacity(0.3)))),
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                            child: Column(
                                          children: <Widget>[
                                            const Text(
                                              "Cuisine Type",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            ListView.separated(
                                              physics: const ScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount: recipeDetail
                                                  .cuisineType.length,
                                              separatorBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return Divider(
                                                  color: Colors.black
                                                      .withOpacity(0.3),
                                                );
                                              },
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return Center(
                                                  child: Text(
                                                    recipeDetail
                                                        .cuisineType[index],
                                                    style: const TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                );
                                              },
                                            )
                                          ],
                                        )),
                                        Expanded(
                                            child: Column(
                                          children: <Widget>[
                                            const Text(
                                              "Dish Type",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            ListView.separated(
                                              physics: const ScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount:
                                                  recipeDetail.dishType.length,
                                              separatorBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return Divider(
                                                  color: Colors.black
                                                      .withOpacity(0.3),
                                                );
                                              },
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return Center(
                                                  child: Text(
                                                    recipeDetail
                                                        .dishType[index],
                                                    style: const TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                );
                                              },
                                            )
                                          ],
                                        )),
                                        Expanded(
                                            child: Column(
                                          children: <Widget>[
                                            const Text(
                                              "Calories",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              recipeDetail.calories
                                                      .toStringAsFixed(0) +
                                                  " kcal",
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ))
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    const Text(
                                      "Ingredients",
                                      style: TextStyle(
                                          fontSize: 22,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Column(
                                      children: <Widget>[
                                        ListView.separated(
                                          physics: const ScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: recipeDetail
                                              .ingredientLines.length,
                                          separatorBuilder:
                                              (BuildContext context,
                                                  int index) {
                                            return Divider(
                                              color:
                                                  Colors.black.withOpacity(0.3),
                                            );
                                          },
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5.0),
                                              child: Text("· " +
                                                  recipeDetail
                                                      .ingredientLines[index]),
                                            );
                                          },
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Center(
                                      child: ElevatedButton(
                                        onPressed: _launchURL,
                                        child: const Text('Go to instructions'),
                                        style: ElevatedButton.styleFrom(
                                          onPrimary: Colors.white,
                                          primary: Colors.indigo,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  );
                })));
  }
}
