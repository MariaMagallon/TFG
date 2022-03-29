import 'dart:convert';
import 'dart:core';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tfg/models/recipe_api.dart';
import 'package:tfg/models/recipe_detail.dart';
import 'package:tfg/screens/searchscreen.dart';

class DetailScreen extends StatelessWidget {
  final String PidRecipe;

  DetailScreen({
    Key? key,
    required this.PidRecipe,
  }) : super(key: key);

  RecipeDetail recipeDetail = RecipeDetail(label: "label", image: "image", uri: "uri", url: "url", calories: 0.0, ingredientLines: [], dishType: [], healthLabels: [], cuisineType: []);
  bool isloading = false;

  String applicationId = 'b702e461';
  String applicationKey = '1bdbca0d4344e3db6103b072c21f38f1';

  Future<RecipeDetail> getRecipe() async {
    final url = Uri.parse(
        "https://api.edamam.com/api/recipes/v2/$PidRecipe?type=public&app_id=$applicationId&app_key=$applicationKey");

    var response = await http.get(url);

    print(response);

    Map<String, dynamic> jsonData = jsonDecode(response.body);

    recipeDetail = RecipeDetail.fromMap(jsonData["recipe"]);
    print(recipeDetail.label);
    
    return await recipeDetail;
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
                leading: IconButton(
                  onPressed: () => {
                    Navigator.pop(context),
                  },
                  icon: Icon(Icons.arrow_back_sharp),
                  iconSize: 30.0,
                )),
            body: FutureBuilder(
                future: getRecipe(),
                builder: (context, AsyncSnapshot<RecipeDetail> snapshot) {
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
                        Container(
                         
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Image.network(
                              recipeDetail.image,
                              fit: BoxFit.cover,
                              height: size.height *0.55,
                            ),
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
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(50),
                                      topRight: Radius.circular(50),
                                    )),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                        child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
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
                                    )),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Text(
                                          recipeDetail.label,
                                          style: TextStyle(
                                              fontSize: 19,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Spacer(),
                                        IconButton(
                                          onPressed: () {},
                                          color: Colors.redAccent,
                                          icon: Icon(Icons.favorite),
                                          iconSize: 30,
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                        child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  border: Border.all(
                                                      color: Colors.grey.withOpacity(0.3)))),
                                        )
                                      ],
                                    )),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                        child: Row(
                                      children: <Widget>[
                                          Expanded(
                                            child: Column(
                                          children: <Widget>[
                                            Text(
                                              "Cuisine Type",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ListView.separated(
                                          physics: ScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: recipeDetail.cuisineType.length,
                                          separatorBuilder:
                                              (BuildContext context, int index) {
                                            return Divider(
                                              color:Colors.black.withOpacity(0.3),
                                                );
                                          },
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Center(
                                            
                                              child: Text(
                                              recipeDetail.cuisineType[index],
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            );
                                          },
                                        )
                                          ],
                                        )),
                                        Expanded(
                                            child: Column(
                                          children: <Widget>[
                                            Text(
                                              "Dish Type",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ListView.separated(
                                          physics: ScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: recipeDetail.dishType.length,
                                          separatorBuilder:
                                              (BuildContext context, int index) {
                                            return Divider(
                                              color:Colors.black.withOpacity(0.3),
                                                );
                                          },
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Center(
                                            
                                              child: Text(
                                              recipeDetail.dishType[index],
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            );
                                          },
                                        )
                                          ],
                                        )),
                                        Expanded(
                                            child: Column(
                                          children: <Widget>[
                                            Text(
                                              "Calories",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              recipeDetail.calories.toString() +" kcal",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ))
                                      ],
                                    )),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      "Ingredients",
                                      style: TextStyle(
                                          fontSize: 22,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Expanded(
                                        child: Column(
                                      children: <Widget>[
                                        ListView.separated(
                                          physics: ScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: recipeDetail.ingredientLines.length,
                                          separatorBuilder:
                                              (BuildContext context, int index) {
                                            return Divider(
                                              color:Colors.black.withOpacity(0.3),
                                                );
                                          },
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(vertical: 5.0),
                                              child: Text("· " + recipeDetail.ingredientLines[index]),
                                            );
                                          },
                                        )
                                      ],
                                    ))
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
