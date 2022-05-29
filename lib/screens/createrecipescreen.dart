import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:tfg/models/own_recipe.dart';
import 'package:tfg/models/recipe.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tfg/widgets/navigation_drawer_widget.dart';

final db = FirebaseFirestore.instance;
FirebaseStorage storageRef = FirebaseStorage.instance;

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({
    Key? key,
  }) : super(key: key);

  @override
  _CreateRecipeScreenState createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  late TextEditingController controllerlabel;
  late TextEditingController controllerdescription;
  late TextEditingController controllercalories;
  late TextEditingController controlleringredient;
  late TextEditingController controllerdish;
  late TextEditingController controllerhealth;
  late TextEditingController controllercuisine;

  final user = FirebaseAuth.instance.currentUser!;
  Recipe recipe = Recipe(
      label: "label",
      image: "image",
      uri: "uri",
      url: "url",
      calories: 0.0,
      ingredientLines: [],
      dishType: [],
      healthLabels: [],
      cuisineType: []);

  String imageName = "";
  XFile? imagePath;
  final ImagePicker _picker = ImagePicker();
  //var descriptionController = new TextEditingController();
  bool _isloading = false;

  @override
  void initState() {
    super.initState();
    controllerlabel = TextEditingController();
    controllerdescription=TextEditingController();
    controllercalories = TextEditingController();
    controlleringredient = TextEditingController();
    controllerhealth = TextEditingController();
    controllercuisine = TextEditingController();
    controllerdish = TextEditingController();
  }

  @override
  void dispose() {
    controllerlabel.dispose();
    super.dispose();
  }

  imagePicker() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        imagePath = image;
        imageName = image.name.toString();
        //descriptionController.text = Faker().lorem.sentence();
      });
    }
  }

  _uploadImage(String id) async {
    setState(() {
      _isloading = true;
    });

    String uploadFileName =
        DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
    Reference reference =
        storageRef.ref().child('recipes').child(uploadFileName);
    UploadTask uploadTask = reference.putFile(File(imagePath!.path));
    uploadTask.snapshotEvents.listen((event) {
      print(event.bytesTransferred.toString() +
          "\t" +
          event.totalBytes.toString());
    });
    await uploadTask.whenComplete(() async {
      var uploadPath = await uploadTask.snapshot.ref.getDownloadURL();

      if (uploadPath.isNotEmpty) {
        db
            .collection("userData")
            .doc(user.uid)
            .collection("recipes")
            .doc(id)
            .update({
          //"description": descriptionController.text,
          "image": uploadPath,
        }).then((value) => _showMessage("Image uploaded successfully"));
      } else {
        _showMessage("Something while uploading image");
      }
      setState(() {
        _isloading = false;
      });
    });
  }

  _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      duration: const Duration(seconds: 3),
    ));
  }

  _buildHealthField() {
    return SizedBox(
      width: 200,
      child: TextField(
        controller: controllerhealth,
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(labelText: 'Health Label'),
        style: const TextStyle(fontSize: 20),
      ),
    );
  }

  _addHealth(String text) {
    if (text.isNotEmpty) {
      setState(() {
        recipe.healthLabels.add(text);
      });
      controllerhealth.clear();
    }
  }

  _buildCuisineField() {
    return SizedBox(
      width: 200,
      child: TextField(
        controller: controllercuisine,
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(labelText: 'Cuisine Type'),
        style: const TextStyle(fontSize: 20),
      ),
    );
  }

  _addCuisine(String text) {
    if (text.isNotEmpty) {
      setState(() {
        recipe.cuisineType.add(text);
      });
      controllercuisine.clear();
    }
  }

  _buildDishField() {
    return SizedBox(
      width: 200,
      child: TextField(
        controller: controllerdish,
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(labelText: 'Dish Type'),
        style: const TextStyle(fontSize: 20),
      ),
    );
  }

  _addDish(String text) {
    if (text.isNotEmpty) {
      setState(() {
        recipe.dishType.add(text);
      });
      controllerdish.clear();
    }
  }

  _buildSubingredientField() {
    return SizedBox(
      width: 200,
      child: TextField(
        controller: controlleringredient,
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(labelText: 'Subingredient'),
        style: const TextStyle(fontSize: 20),
      ),
    );
  }

  _addSubingredient(String text) {
    if (text.isNotEmpty) {
      setState(() {
        recipe.ingredientLines.add(text);
      });
      controlleringredient.clear();
    }
  }

  void _removeField(int index) {
    recipe.ingredientLines.removeAt(index);
    //widget.onUpdate(fields);
    setState(() {});
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
                leading: IconButton(
                  onPressed: () => {
                    Navigator.pop(context),
                  },
                  icon: const Icon(Icons.arrow_back_sharp),
                  iconSize: 30.0,
                )),
            endDrawer: const NavigationDrawerWidget(),
            body: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: _isloading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Create a new recipe",
                              style: TextStyle(
                                fontSize: 30,
                              )),
                          const SizedBox(height: 30),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 40.0, right: 40.0),
                            child: TextField(
                                style: const TextStyle(color: Colors.black),
                                decoration: const InputDecoration(
                                  labelText: "Title",
                                  filled: true,
                                  fillColor: Color.fromRGBO(255, 255, 255, 0.5),
                                ),
                                controller: controllerlabel),
                          ),
                          const SizedBox(height: 30),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 40.0, right: 40.0),
                            child: TextField(
                                style: const TextStyle(color: Colors.black),
                                decoration: const InputDecoration(
                                  labelText: "Instructions",
                                  filled: true,
                                  fillColor: Color.fromRGBO(255, 255, 255, 0.5),
                                ),
                                controller: controllerdescription),
                          ),
                          const SizedBox(height: 30),
                          imageName == "" ? Container() : Text(imageName),
                          const SizedBox(height: 10),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 40.0, right: 40.0),
                            child: TextField(
                                style: const TextStyle(color: Colors.black),
                                decoration: const InputDecoration(
                                  labelText: "Calories",
                                  filled: true,
                                  fillColor: Color.fromRGBO(255, 255, 255, 0.5),
                                ),
                                /*keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                ],*/
                                controller: controllercalories),
                          ),
                          const SizedBox(height: 30),
                          OutlinedButton(
                              onPressed: () {
                                imagePicker();
                              },
                              child: const Text('Select image')),
                          const SizedBox(height: 10),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 40.0, right: 40.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                _buildSubingredientField(),
                                ButtonTheme(
                                  child: ElevatedButton(
                                    child: const Text('Add',
                                        style: TextStyle(color: Colors.white)),
                                    onPressed: () => _addSubingredient(
                                        controlleringredient.text),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          GridView.count(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            padding: const EdgeInsets.all(8),
                            crossAxisCount: 3,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                            children: recipe.ingredientLines
                                .map(
                                  (ingredient) => Card(
                                    color: Colors.indigo,
                                    child: Center(
                                      child: Text(
                                        ingredient,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 40.0, right: 40.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                _buildHealthField(),
                                ButtonTheme(
                                  child: ElevatedButton(
                                    child: const Text('Add',
                                        style: TextStyle(color: Colors.white)),
                                    onPressed: () =>
                                        _addHealth(controllerhealth.text),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          GridView.count(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            padding: const EdgeInsets.all(8),
                            crossAxisCount: 3,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                            children: recipe.healthLabels
                                .map(
                                  (health) => Card(
                                    color: Colors.indigo,
                                    child: Center(
                                      child: Text(
                                        health,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 40.0, right: 40.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                _buildDishField(),
                                ButtonTheme(
                                  child: ElevatedButton(
                                    child: const Text('Add',
                                        style: TextStyle(color: Colors.white)),
                                    onPressed: () =>
                                        _addDish(controllerdish.text),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          GridView.count(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            padding: const EdgeInsets.all(8),
                            crossAxisCount: 3,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                            children: recipe.dishType
                                .map(
                                  (dish) => Card(
                                    color: Colors.indigo,
                                    child: Center(
                                      child: Text(
                                        dish,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 40.0, right: 40.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                _buildCuisineField(),
                                ButtonTheme(
                                  child: ElevatedButton(
                                    child: const Text('Add',
                                        style: TextStyle(color: Colors.white)),
                                    onPressed: () =>
                                        _addCuisine(controllercuisine.text),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          GridView.count(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            padding: const EdgeInsets.all(8),
                            crossAxisCount: 3,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                            children: recipe.cuisineType
                                .map(
                                  (cuisine) => Card(
                                    color: Colors.indigo,
                                    child: Center(
                                      child: Text(
                                        cuisine,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: ElevatedButton(
                              onPressed: () async {
                                recipe.label = controllerlabel.text;
                                recipe.calories =
                                    double.tryParse(controllercalories.text)!;
                                recipe.description=controllerdescription.text;
                                recipe.isapi = 0;
                                await createRecipe(recipe);
                                await _uploadImage(recipe.id!);
                              },
                              child: const Text(
                                'Save Recipe',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                onPrimary: Colors.white,
                                primary: Colors.indigo,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            )));
  }
}


