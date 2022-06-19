import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tfg/models/recipe.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tfg/widgets/editablefield_widget.dart';
import 'package:tfg/widgets/navigation_drawer_widget.dart';

final db = FirebaseFirestore.instance;
FirebaseStorage storageRef = FirebaseStorage.instance;

class CreateModifyRecipeScreen extends StatefulWidget {
  Recipe precipe = Recipe(
      label: "",
      image: "",
      uri: "",
      url: "",
      calories: 0.0,
      ingredientLines: [],
      dishType: [],
      healthLabels: [],
      cuisineType: []);

  bool iscreating;

  CreateModifyRecipeScreen(
      {Key? key, required this.precipe, required this.iscreating})
      : super(key: key);

  @override
  _CreateModifyRecipeScreenState createState() =>
      _CreateModifyRecipeScreenState();
}

class _CreateModifyRecipeScreenState extends State<CreateModifyRecipeScreen> {
  late TextEditingController controllerlabel;
  late TextEditingController controllerdescription;
  late TextEditingController controllercalories;
  late TextEditingController controlleringredient;
  late TextEditingController controllerdish;
  late TextEditingController controllerhealth;
  late TextEditingController controllercuisine;
  late List<String> listingredients = [];
  late List<String> listhealth = [];
  late List<String> listcuisine = [];
  late List<String> listdish = [];

  
  Recipe _recipe = Recipe(
      label: "",
      image: "",
      uri: "",
      url: "",
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
  bool iscreating = false;
  String textbotonsave = "";
  bool isimagemodified = false;
  String imagePathModified = "";
  bool icansave = true;

  @override
  void initState() {
    super.initState();
    controllerlabel = TextEditingController();
    controllerdescription = TextEditingController();
    controllercalories = TextEditingController();
    controlleringredient = TextEditingController();
    controllerhealth = TextEditingController();
    controllercuisine = TextEditingController();
    controllerdish = TextEditingController();

    iscreating = widget.iscreating;

    if (iscreating == true) {
      textbotonsave = "Save Recipe";
    } else {
      textbotonsave = "Update Recipe";
      _recipe = widget.precipe;
      controllerlabel.text = _recipe.label;
      controllercalories.text = (_recipe.calories).toString();
      if (_recipe.description != null) {
        controllerdescription.text = _recipe.description!;
      }

      for (int i = 0; i < _recipe.ingredientLines.length; i++) {
        listingredients.add(_recipe.ingredientLines[i]);
      }

      for (int i = 0; i < _recipe.cuisineType.length; i++) {
        listcuisine.add(_recipe.cuisineType[i]);
      }

      for (int i = 0; i < _recipe.dishType.length; i++) {
        listdish.add(_recipe.dishType[i]);
      }

      for (int i = 0; i < _recipe.healthLabels.length; i++) {
        listhealth.add(_recipe.healthLabels[i]);
      }
    }
  }

  @override
  void dispose() {
    controllerlabel.dispose();
    super.dispose();
  }

  Future<bool> imagePicker() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        imagePath = image;
        imageName = image.name.toString();
        //descriptionController.text = Faker().lorem.sentence();
      });
      return true;
    } else {
      return false;
    }
  }

  Future<String> _uploadImage() async {
    setState(() {
      _isloading = true;
    });
    String uploadPath = "";
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
      uploadPath = await uploadTask.snapshot.ref.getDownloadURL();

      if (uploadPath.isNotEmpty) {
        _showMessage("Image uploaded successfully");
      } else {
        _showMessage("Something while uploading image");
      }
      setState(() {
        _isloading = false;
      });
    });
    return uploadPath;
  }

  _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontSize: 20)),
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.red,
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
        listhealth.add(text);
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
        listcuisine.add(text);
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
        listdish.add(text);
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
        listingredients.add(text);
      });
      controlleringredient.clear();
    }
  }

  _removeField(int index, List list) {
    setState(() {
      list.removeAt(index);
    });
  }

  bool isNumeric(String str) {
    try {
      if (str.isEmpty) {
        return false;
      } else {
        double.parse(str);
        return true;
      }
    } on FormatException {
      return false;
    }
  }

  WidgetShowImage() {
    if (imagePath != null) {
      print('showing image from local file');

      return Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[
          Image.file(
            File(imagePath!.path),
            fit: BoxFit.cover,
            height: 250,
          ),
        ],
      );
    } else if (_recipe.image != "") {
      return Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[
          Image.network(
            _recipe.image,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
            height: 250,
          ),
        ],
      );
    } else {
      return const Text("image placeholder");
    }
  }

 Future <String> editField( List list, int index, String title) async {
 
    final inputfield = await showTextDialog(
      context,
      title: title,
      value: list[index],
      tipoteclado: TextInputType.text,
      poscuro:false,
    );
    if (inputfield==null){
      return "";
    }else{
      setState(() {
        list[index]=inputfield;
      });
      return inputfield;
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
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                      icon: const Icon(Icons.account_circle_rounded),
                      iconSize: 30.0,
                    );
                  }),
                ],
                leading: IconButton(
                  onPressed: () => {
                    Navigator.of(context).pop(),
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

                          WidgetShowImage(),
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
                                keyboardType: TextInputType.number,
                                controller: controllercalories),
                          ),
                          const SizedBox(height: 30),
                          imageName == "" ? Container() : Text(imageName),
                          OutlinedButton(
                              onPressed: () async {
                                isimagemodified = await imagePicker();
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
                          ListView.separated(
                            physics: const ScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: listingredients.length,
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return Divider(
                                color: Colors.black.withOpacity(0.3),
                              );
                            },
                            itemBuilder: (BuildContext context, int index) {
                              return  Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                    children: [
                                      Text(
                                        listingredients[index],
                                        style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      IconButton(
                                        onPressed: () => editField(listingredients, index,"Change the Ingredient"),
                                        icon: const Icon(Icons.edit),
                                        iconSize: 30.0,
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            _removeField(index, listingredients),
                                        icon: const Icon(Icons.delete),
                                        iconSize: 30.0,
                                      ),
                                    ],
                                  ),
                              );
                            },
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
                          ListView.separated(
                            physics: const ScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: listhealth.length,
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return Divider(
                                color: Colors.black.withOpacity(0.3),
                              );
                            },
                            itemBuilder: (BuildContext context, int index) {
                              return  Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                    children: [
                                      Text(
                                        listhealth[index],
                                        style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      IconButton(
                                        onPressed: () => editField( listhealth, index, "Change the health label"),
                                        icon: const Icon(Icons.edit),
                                        iconSize: 30.0,
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            _removeField(index, listhealth),
                                        icon: const Icon(Icons.delete),
                                        iconSize: 30.0,
                                      ),
                                    ],
                                  ),
                              );
                            },
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
                          ListView.separated(
                            physics: const ScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: listdish.length,
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return Divider(
                                color: Colors.black.withOpacity(0.3),
                              );
                            },
                            itemBuilder: (BuildContext context, int index) {
                              return  Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                    children: [
                                      Text(
                                        listdish[index],
                                        style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      IconButton(
                                        onPressed: () => editField( listdish, index, "Change the dish type"),
                                        icon: const Icon(Icons.edit),
                                        iconSize: 30.0,
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            _removeField(index, listdish),
                                        icon: const Icon(Icons.delete),
                                        iconSize: 30.0,
                                      ),
                                    ],
                                  ),
                              );
                            },
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
                          ListView.separated(
                            physics: const ScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: listcuisine.length,
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return Divider(
                                color: Colors.black.withOpacity(0.3),
                              );
                            },
                            itemBuilder: (BuildContext context, int index) {
                              return  Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                    children: [
                                      Text(
                                        listcuisine[index],
                                        style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      IconButton(
                                        onPressed: () => editField( listcuisine, index, "Change the cuisine type"),
                                        icon: const Icon(Icons.edit),
                                        iconSize: 30.0,
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            _removeField(index, listcuisine),
                                        icon: const Icon(Icons.delete),
                                        iconSize: 30.0,
                                      ),
                                    ],
                                  ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          //boton save
                          Center(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (controllerlabel.text.isEmpty) {
                                  _showMessage(
                                      "Recipe title is a required field");
                                  icansave = false;
                                }

                                if (!isNumeric(controllercalories.text)) {
                                  _showMessage(
                                      "Calories must be a numeric value");
                                  icansave = false;
                                }

                                if (icansave) {
                                  _recipe.calories =
                                      double.tryParse(controllercalories.text)!;
                                  _recipe.label = controllerlabel.text;
                                  _recipe.description =
                                      controllerdescription.text;
                                  _recipe.ingredientLines = listingredients;
                                  _recipe.cuisineType = listcuisine;
                                  _recipe.dishType = listdish;
                                  _recipe.healthLabels = listhealth;

                                  if (iscreating == true) {
                                    _recipe.isapi = false;
                                    if (isimagemodified) {
                                      _recipe.image = await _uploadImage();
                                    }
                                    await createRecipe(_recipe);
                                    Navigator.of(context).pop();
                                  } else {
                                    if (isimagemodified) {
                                      if (_recipe.isapi == false) {
                                        await deleteFirestoreStorage(
                                            _recipe.image);
                                      }
                                      imagePathModified =
                                          await _uploadImage(); //subo y asocio imagepath a recipe
                                    }
                                    if (imagePathModified.isNotEmpty) {
                                      _recipe.image = imagePathModified;
                                      _recipe.isapi = false;
                                    }

                                    await updateRecipe(_recipe);
                                    Navigator.of(context).pop(_recipe);
                                  }
                                }
                              },
                              child: Text(
                                (textbotonsave),
                                style: const TextStyle(
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
