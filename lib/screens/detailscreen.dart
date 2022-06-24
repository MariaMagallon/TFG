import 'dart:convert';
import 'dart:core';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:tfg/models/recipe.dart';
import 'package:tfg/screens/createmodifyrecipescreen.dart';
import 'package:tfg/widgets/navigation_drawer_widget.dart';
import 'package:tfg/widgets/showdialog_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tfg/globals/storagefunctions.dart';
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
            
            backgroundColor: Colors.transparent,
            endDrawer: const NavigationDrawerWidget(),
            body: FutureBuilder(
                future: getRecipe(widget.origen, widget.recipeDetail),
                builder: (context, AsyncSnapshot<Recipe> snapshot) {
                  if (snapshot.hasError) {
                    return ErrorWidget(snapshot.error.toString());
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator(color: Colors.teal,));
                  }
                  widget.recipeDetail = snapshot.data!;

                  return Container(
                    color: Colors.teal,
                    width: double.infinity,
                    height: double.infinity,
                    child: Stack(
                      children: <Widget>[
                        (widget.recipeDetail.image != "")
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
                                  color: Colors.teal,
                                ),
                              ),
                        Transform.translate(
                          offset: const Offset(-10, 35),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: FloatingActionButton(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              heroTag: null,
                              onPressed: () {},
                              child: IconButton(
                                onPressed: () {
                                  Scaffold.of(context).openEndDrawer();
                                },
                                icon: const Icon(Icons.account_circle_rounded),
                                iconSize: 40.0,
                                color: Colors.teal,
                              ),
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(-0.2, 35),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: FloatingActionButton(
                              heroTag: null,
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              onPressed: () {},
                              child: IconButton(
                                onPressed: () => {
                                  Navigator.of(context).pop(),
                                },
                                icon: const Icon(Icons.arrow_back_sharp),
                                iconSize: 40.0,
                                color: Colors.teal,
                              ),
                            ),
                          ),
                        ),
                        DraggableScrollableSheet(
                          maxChildSize: 0.9,
                          initialChildSize: 0.5,
                          minChildSize: 0.5,
                          builder: (context, controller) {
                            return SingleChildScrollView(
                              controller: controller,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                height: 1500,
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
                                          borderRadius:BorderRadius.circular(10),
                                            border: Border.all(color: Colors.grey))),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      children: <Widget>[
                                        SizedBox(
                                         width: 270,
                                          child: Text(
                                            widget.recipeDetail.label.toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 25,
                                              color: Colors.black,
                                              fontFamily: "Heebo",
                                              fontWeight: FontWeight.bold),
                                              overflow: TextOverflow.clip,
                                              
                                          ),
                                        ),
                                        const Spacer(
                                          flex: 50,
                                        ),
                                        widget.origen == 0
                                            ? IconButton(
                                                onPressed: () async {
                                                  widget.recipeDetail.idapi =edamamId(widget.recipeDetail.uri);
                                                  bool existidapi =await existFirestoreRecipe(
                                                    widget.recipeDetail.idapi!);
                                                  String ltitle ="Saving Recipe...";
                                                  String lcontent = "";
                                                  if (existidapi) {
                                                    lcontent ="This recipe was not saved because it already exists in your saved recipes list ";
                                                  } else {
                                                    widget.recipeDetail.isapi =true;
                                                    await createRecipe(widget.recipeDetail);
                                                    lcontent =" This recipe has been successfully saved";
                                                  }
                                                  await showMyDialog(context,ltitle, lcontent);
                                                  Navigator.pop(context);
                                                },
                                                color: Colors.teal,
                                                icon:
                                                const Icon(Icons.bookmark),
                                                iconSize: 35,
                                              )
                                            : const Spacer(),
                                        const Spacer(),
                                        //casos origen = firestore API (1) i firestore own(2) mostrar boto delete de firestore
                                        widget.origen >= 1
                                            ? IconButton(
                                                onPressed: () async {
                                                  String ltitle ="Deleting Recipe...";
                                                  String lcontent ="The recipe has been successfully deleted";
                                                  await deleteFirestoreRecipe(widget.recipeDetail.id!);
                                                  if (widget.origen == 2) {
                                                    await deleteFirestoreStorage(widget.recipeDetail.image);
                                                  }
                                                  await showMyDialog(context,ltitle, lcontent);
                                                  Navigator.pop(context);
                                                },
                                                color: Colors.teal,
                                                icon: const Icon(Icons.delete),
                                                iconSize: 30,
                                              )
                                            : const Spacer(),

                                        const Spacer(),
                                        //modify icon
                                        widget.origen >= 1
                                            ? IconButton(
                                                onPressed: () async {
                                                  Navigator.of(context).push(MaterialPageRoute(
                                                    builder: (context) =>
                                                        CreateModifyRecipeScreen(precipe: widget.recipeDetail,iscreating: false),
                                                  )) .then((result) {
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
                                                color: Colors.teal,
                                                icon: const Icon(Icons.mode_edit),
                                                iconSize: 30,
                                              )
                                            : const Text(""),
                                      ],
                                    ),
                                    
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:BorderRadius.circular(5),
                                                  border: Border.all(
                                                    color: Colors.grey.withOpacity(0.3)))),
                                        )
                                      ],
                                    ),
                                    Center(
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Column(
                                            children: <Widget>[
                                            const SizedBox(
                                                height: 26,
                                              ),        
                                              const Text(
                                                "Cuisine Type",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                              Transform.translate(
                                                offset: const Offset(0, -30),
                                                child: ListView.builder(
                                                  
                                                  shrinkWrap: true,
                                                  itemCount: widget.recipeDetail.cuisineType.length,
                                                  
                                                  itemBuilder:
                                                      (BuildContext context, int index) {
                                                    return Center(
                                                      child: Text(
                                                        widget.recipeDetail.cuisineType[index],
                                                        style: const TextStyle(
                                                            fontSize: 15,
                                                            color: Colors.black,
                                                            fontWeight: FontWeight.bold),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          )),
                                          Expanded(     
                                                             
                                              child: Transform.rotate(
                                                angle: 1.57,
                                                child: Container(
                                                height: 2,
                                                width: 0.2,
                                                color: const Color.fromRGBO(255, 193, 7, 1),
                                                ),
                                              ),
                                            ),
                                          Expanded(
                                            child: Column(
                                            children: <Widget>[
                                            const SizedBox(
                                                height: 26,
                                              ),        
                                              const Text(
                                                "Dish Type",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                              Transform.translate(
                                                offset: const Offset(0, -30),
                                                child: ListView.builder(
                                                  
                                                  shrinkWrap: true,
                                                  itemCount: widget.recipeDetail.dishType.length,
                                                  
                                                  itemBuilder:
                                                      (BuildContext context, int index) {
                                                    return Center(
                                                      child: Text(
                                                        widget.recipeDetail.dishType[index],
                                                        style: const TextStyle(
                                                            fontSize: 15,
                                                            color: Colors.black,
                                                            fontWeight: FontWeight.bold),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          )),
                                          Expanded(                    
                                              child: Transform.rotate(
                                                angle: 1.57,
                                                child: Container(
                                                height: 2,
                                                width: 0.2,
                                                color: Colors.amber,
                                                
                                               ),
                                              ),
                                            ),
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
                                    ),

                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      children:  [
                                        const Text(
                                          "Health Lebels",
                                          style: TextStyle(
                                              fontSize: 22,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        IconButton(
                                          onPressed: (){}, 
                                          icon: const Icon(Icons.spa,
                                            color: Colors.teal, size: 30.0),
                                        
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:BorderRadius.circular(5),
                                                  border: Border.all(
                                                    width:1,
                                                    color: Colors.amber))),
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Column(
                                      children: <Widget>[
                                        SizedBox(
                                            height: 50,
                                            child: ListView.builder(
                                                shrinkWrap: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: widget.recipeDetail.healthLabels.length,
                                                itemBuilder: (context, index) {
                                                  return Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 10),
                                                    margin: const EdgeInsets.symmetric( horizontal: 5),
                                                    decoration: BoxDecoration(
                                                        color: Colors.teal.withOpacity(0.7),
                                                        borderRadius: BorderRadius.circular(15)),
                                                    child: Center(
                                                      child: Text(
                                                          widget.recipeDetail.healthLabels[index],
                                                          style: const TextStyle(
                                                              fontSize: 19,
                                                              color:Colors.white,
                                                              fontFamily:"Heebo",
                                                              fontWeight:
                                                                  FontWeight.bold)),
                                                    ),
                                                  );
                                                })),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 30,
                                    ),

                                    Row(
                                      children:  [
                                        const Text(
                                          "Ingredients",
                                          style: TextStyle(
                                              fontSize: 22,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        IconButton(
                                          onPressed: (){}, 
                                          icon: const Icon(Icons.lunch_dining,
                                            color: Colors.teal, size: 30.0),
                                        
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:BorderRadius.circular(5),
                                                  border: Border.all(
                                                    width:1,
                                                    color: Colors.amber))),
                                        )
                                      ],
                                    ),
                                     const SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      children: [
                                        Column(
                                          children: <Widget>[
                                            Container(
                                                height: 550,
                                                width: 370,
                                                
                                                decoration: BoxDecoration(
                                                        color: Colors.teal.withOpacity(0.6),
                                                        borderRadius: BorderRadius.circular(15)),
                                                padding: const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 20),
                                                
                                                child: ListView.builder(
                                                    itemCount: widget.recipeDetail.ingredientLines.length,
                                                    itemBuilder: (context, index) {
                                                      return 
                                                           Row(
                                                             children: [
                                                              const Text(
                                                                "• ", 
                                                                style: TextStyle( fontSize: 22,
                                                                      color: Colors.white,
                                                                      fontFamily: "Heebo",
                                                                      fontWeight: FontWeight.bold,
                                                                      overflow: TextOverflow.clip)
                                                              ),
                                                              
                                                               Text(
                                                                  widget.recipeDetail.ingredientLines[index],
                                                                  style: const TextStyle( fontSize: 15,
                                                                      color: Colors.white,
                                                                      fontFamily: "Heebo",
                                                                      fontWeight: FontWeight.bold,
                                                                      overflow: TextOverflow.clip
                                                                      )),
                                                             ],
                                                           );
                                                        
                                                      
                                                    })),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    
                                    //casos origen = API pur (0) i firestore API(1) //ha d'apareixer boto instruc o camp descripcio propia
                                    Row(
                                      children:  [
                                        const Text(
                                          "Preparation",
                                          style: TextStyle(
                                              fontSize: 22,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                         IconButton(
                                          onPressed: (){}, 
                                          icon: const Icon(Icons.menu_book,
                                            color: Colors.teal, size: 30.0),
                                        
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:BorderRadius.circular(5),
                                                  border: Border.all(
                                                    width:1,
                                                    color: Colors.amber))),
                                        )
                                      ],
                                    ),
                                  
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Text(widget.recipeDetail.description!, style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.black,
                                    )),
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    widget.origen <= 1
                                        ? Center(
                                            child: ElevatedButton(
                                              onPressed: _launchURL,
                                              child: const Text(
                                                  'Go to instructions', 
                                                  style: TextStyle( 
                                                    fontSize: 19,
                                                    color: Colors.white,
                                                    fontFamily: "Heebo",
                                                    fontWeight: FontWeight.bold)),
                                              style: ElevatedButton.styleFrom(
                                                onPrimary: Colors.white,
                                                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                                primary: Colors.teal,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(15)),
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
