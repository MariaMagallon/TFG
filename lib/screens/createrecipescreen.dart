import 'dart:io';

import 'package:faker/faker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tfg/models/own_recipe.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
  late TextEditingController controller;
  final user = FirebaseAuth.instance.currentUser!;
  late OwnRecipe ownRecipe = OwnRecipe(label: "label", image:"image", description:"description");
  String imageName = "";
  XFile? imagePath;
  final ImagePicker _picker = ImagePicker();
  var descriptionController = new TextEditingController();
  bool _isloading=false;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  imagePicker() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        imagePath = image;
        imageName = image.name.toString();
        descriptionController.text = Faker().lorem.sentence();
      });
    }
  }

  _uploadImage(String id ) async {
    setState(() {
      _isloading=true;
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
        db.collection("userData").doc(user.uid).collection("recipes").doc(id).update({
          "description": descriptionController.text,
          "image": uploadPath,
          


        }).then((value) => _showMessage("Record Insert"));
      }else{
        _showMessage("Something while uploading image");

      }
      setState(() {
        _isloading=false;
      });
    });
  }

  _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      duration: const Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // Aquí es retorna cert o false segons si vols prevenir que es pugui tornar enrere
          return true;
        },
        child: Scaffold(
            body: Container(
          decoration: const BoxDecoration(
            color:  Color.fromRGBO(104, 177, 236, 1),
          ),
          child: _isloading ? const Center(child: CircularProgressIndicator()) : Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Create a new recipe",
                  style: TextStyle(
                    fontSize: 30,
                  )),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.only(left: 40.0, right: 40.0),
                child: TextField(
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      labelText: "Label",
                      filled: true,
                      fillColor: Color.fromRGBO(255, 255, 255, 0.5),
                    ),
                    controller: controller),
              ),
              const SizedBox(height: 30),
              imageName == "" ? Container() : Text(imageName),
              const SizedBox(height: 10),
              OutlinedButton(
                  onPressed: () {
                    imagePicker();
                  },
                  child: const Text('Select image')),
              const SizedBox(height: 10),
              TextFormField(
                controller: descriptionController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                    labelText: 'Description', border: OutlineInputBorder()),
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () async{
                  ownRecipe.label = controller.text;
                  await createRecipe(ownRecipe);
                  _uploadImage(ownRecipe.id!);

                  },
                  child: const Text(
                    'Save Recipe',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    onPrimary: Colors.white,
                    primary: Colors.indigo,
                  ),
                ),
              ),
             
            ],
          ),
        )));
  }
}
