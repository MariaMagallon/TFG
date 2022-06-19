import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:tfg/models/recipe.dart';
import 'package:tfg/screens/createrecipescreen.dart';
import 'package:tfg/widgets/navigation_drawer_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfg/globals/apikeys.dart';

final db = FirebaseFirestore.instance;

class DetailScreen extends StatefulWidget {
  String pidRecipe;
  int origen;

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

  DetailScreen(
      {Key? key,
      required this.pidRecipe,
      required this.origen,
      required this.recipeDetail})
      : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool isloading = false;

  

  Future<Recipe> getRecipe(int origen, Recipe recipeDetail) async {
    if (origen == 2) {
      return recipeDetail;
    } else {
      final url = Uri.parse(
          "https://api.edamam.com/api/recipes/v2/${widget.pidRecipe}?type=public&app_id=$applicationId&app_key=$applicationKey");

      var response = await http.get(url);

      Map<String, dynamic> jsonData = jsonDecode(response.body);
      Recipe recipeAux;
      recipeAux = Recipe.fromMap(jsonData["recipe"]);
      if (origen == 0) {
        recipeAux.description = "This recipe comes from the API";
        return recipeAux;
      } else {
        recipeDetail.image = recipeAux.image;
        return recipeDetail;
      }
    }
  }

  Future<void> _showMyDialog(
      BuildContext context, String ptitle, String pcontent) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(ptitle),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(pcontent),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _launchURL() async {
    if (!await launch(widget.recipeDetail.url)) {
      throw 'Could not launch' + widget.recipeDetail.url;
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
                future: getRecipe(widget.origen, widget.recipeDetail),
                builder: (context, AsyncSnapshot<Recipe> snapshot) {
                  if (snapshot.hasError) {
                    return ErrorWidget(snapshot.error.toString());
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  widget.recipeDetail = snapshot.data!;

                  return Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Stack(
                      children: <Widget>[
                        widget.recipeDetail.image != ""
                            ? Align(
                                alignment: Alignment.topCenter,
                                child: Image.network(
                                  widget.recipeDetail.image,
                                  fit: BoxFit.cover,
                                  height: size.height * 0.55,
                                ),
                              )
                            : Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  width: double.infinity,
                                  height: size.height * 0.55,
                                  color: Colors.blue,
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
                                          widget.recipeDetail.label,
                                          style: const TextStyle(
                                              fontSize: 19,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const Spacer(),
                                        widget.origen == 0
                                            ? IconButton(
                                                onPressed: () async {
                                                  widget.recipeDetail.idapi =
                                                      edamamId(widget
                                                          .recipeDetail.uri);
                                                  bool existidapi =
                                                      await existFirestoreRecipe(
                                                          widget.recipeDetail
                                                              .idapi!);
                                                  String ltitle =
                                                      "Saving Recipe...";
                                                  String lcontent = "";
                                                  if (existidapi) {
                                                    lcontent =
                                                        "This recipe was not saved because it already exists in your saved recipes list ";
                                                  } else {
                                                    widget.recipeDetail.isapi =
                                                        true;
                                                    await createRecipe(
                                                        widget.recipeDetail);
                                                    lcontent =
                                                        " This recipe has been successfully saved";
                                                  }

                                                  await _showMyDialog(context,
                                                      ltitle, lcontent);
                                                  Navigator.pop(context);
                                                },
                                                color: Colors.redAccent,
                                                icon: const Icon(Icons.save),
                                                iconSize: 30,
                                              )
                                            : const Spacer(),
                                        const Spacer(),
                                        //casos origen = firestore API (1) i firestore own(2) mostrar boto delete de firestore
                                        widget.origen >= 1
                                            ? IconButton(
                                                onPressed: () async {
                                                  String ltitle =
                                                      "Deleting Recipe...";
                                                  String lcontent =
                                                      "The recipe has been successfully deleted";
                                                  await deleteFirestoreRecipe(
                                                      widget.recipeDetail.id!);
                                                  if (widget.origen == 2) {
                                                    await deleteFirestoreStorage(
                                                        widget.recipeDetail
                                                            .image);
                                                  }
                                                  await _showMyDialog(context,
                                                      ltitle, lcontent);
                                                  Navigator.pop(context);
                                                },
                                                color: Colors.redAccent,
                                                icon: const Icon(Icons.delete),
                                                iconSize: 30,
                                              )
                                            : const Text("save"),

                                        const Spacer(),
                                        //modify icon
                                        widget.origen >= 1
                                            ? IconButton(
                                                onPressed: () async {
                                                  Navigator.of(context)
                                                      .push(MaterialPageRoute(
                                                    builder: (context) =>
                                                        CreateModifyRecipeScreen(
                                                            precipe: widget
                                                                .recipeDetail,
                                                            iscreating: false),
                                                  ))
                                                      .then((result) {
                                                    if (result != null) {
                                                      setState(() {
                                                        widget.recipeDetail =
                                                            result;
                                                        if (widget.recipeDetail
                                                                .isapi ==
                                                            false) {
                                                          widget.origen = 2;
                                                        }
                                                      });
                                                    }
                                                  });
                                                },
                                                color: Colors.redAccent,
                                                icon:
                                                    const Icon(Icons.mode_edit),
                                                iconSize: 30,
                                              )
                                            : const Text(""),
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
                                              itemCount: widget.recipeDetail
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
                                                    widget.recipeDetail
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
                                              itemCount: widget
                                                  .recipeDetail.dishType.length,
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
                                                    widget.recipeDetail
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
                                              widget.recipeDetail.calories
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
                                          itemCount: widget.recipeDetail
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
                                                  widget.recipeDetail
                                                      .ingredientLines[index]),
                                            );
                                          },
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    //casos origen = API pur (0) i firestore API(1) //ha d'apareixer boto instruc o camp descripcio propia
                                    Center(
                                        child: Text(
                                            widget.recipeDetail.description!)),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    widget.origen <= 1
                                        ? Center(
                                            child: ElevatedButton(
                                              onPressed: _launchURL,
                                              child: const Text(
                                                  'Go to instructions'),
                                              style: ElevatedButton.styleFrom(
                                                onPrimary: Colors.white,
                                                primary: Colors.indigo,
                                              ),
                                            ),
                                          )
                                        : const SizedBox(
                                            height: 5,
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
