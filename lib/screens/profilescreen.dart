import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfg/globals/globalvariables.dart';
import 'package:tfg/widgets/editablefield_widget.dart';
import 'package:tfg/widgets/passwordchange.dart';
import 'package:tfg/widgets/navigation_drawer_widget.dart';
import 'package:tfg/globals/storagefunctions.dart';

final db = FirebaseFirestore.instance;
FirebaseStorage storageRef = FirebaseStorage.instance;

class ProfilePageScreen extends StatefulWidget {
  const ProfilePageScreen({Key? key}) : super(key: key);

  @override
  _ProfilePageScreenState createState() => _ProfilePageScreenState();
}

class _ProfilePageScreenState extends State<ProfilePageScreen> {
  String imageName = "";
  XFile? imagePath;
  final ImagePicker _picker = ImagePicker();
  bool _isloading = false;
  late TextEditingController controllerdisplayname;
  late TextEditingController controlleremail;
  String oldPath="";
  String newPath="";


  @override
  void initState() {
    super.initState();
    controllerdisplayname = TextEditingController();
    controlleremail = TextEditingController();
    if (user.displayName != null) {
      controllerdisplayname.text = user.displayName!;
    }
    if (user.email != null) {
      controlleremail.text = user.email!;
    }
    if (user.photoURL !=null){
      oldPath=user.photoURL!;
    }else{
      oldPath="";
    }
    newPath=oldPath;
  }

  Future<bool> imagePicker() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        imagePath = image;
        imageName = image.name.toString();
        
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
        storageRef.ref().child('profile').child(uploadFileName);
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
      duration: const Duration(seconds: 4),
      backgroundColor: Colors.red,
    ));
  }

  Future changePassword() async {
    await showTextDialogPassword(
      context,
    );
  }

  Future<String> editField(String title, String value) async {
    String? inputfield = await showTextDialog(
      context,
      title: title,
      value: value,
      tipoteclado: TextInputType.text,
      poscuro: true,
    );
    if (inputfield == null) {
      return "";
    } else {
      return inputfield;
    }
  }
  
  widgetShowImage() {
    if (imagePath != null) {
      print('showing image from local file');
      return Stack(
        children: <Widget>[
          CircleAvatar(
            radius: 100,
            child: ClipOval(
              child: SizedBox(
                  width: 180.0,
                  height: 180.0,
                  child: Image.file(
                    File(imagePath!.path),
                    fit: BoxFit.fill,
                  )),
            ),
          ),
        ],
      );
    } else if ((user.photoURL)!=null) {
      return Stack(
        children: <Widget>[
          CircleAvatar(
            radius: 100,
            child: ClipOval(
              child: SizedBox(
                  width: 180.0,
                  height: 180.0,
                  child: Image.network(
                    user.photoURL!,
                    fit: BoxFit.fill,
                  )),
            ),
          ),
        ],
      );
    } else {
      return const CircleAvatar(
        radius: 100,
        child: ClipOval(
          child: SizedBox(
            width: 180.0,
            height: 180.0,
            child: Icon(
              Icons.account_circle_rounded,
              size: 180.0,
              color: Colors.white,
            ),
          ),
        ),
      );
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
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: _isloading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(
                          height: 20.0,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            widgetShowImage(),
                            Transform.translate(
                              offset: const Offset(-50, 50),
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: Colors.amber),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt_rounded,
                                    size: 40.0,
                                  ),
                                  onPressed: () async {
                                    if (await imagePicker()){
                                      newPath=imagePath!.path;
                                    }

                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 40.0, right: 40.0),
                          child: TextField(
                              style: const TextStyle(color: Colors.black),
                              decoration: const InputDecoration(
                                labelText: "Nickname",
                                filled: true,
                                fillColor: Color.fromRGBO(255, 255, 255, 0.5),
                              ),
                              controller: controllerdisplayname),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 40.0, right: 40.0),
                          child: TextField(
                              style: const TextStyle(color: Colors.black),
                              decoration: const InputDecoration(
                                labelText: "Email",
                                filled: true,
                                fillColor: Color.fromRGBO(255, 255, 255, 0.5),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              controller: controlleremail),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: ElevatedButton(
                            onPressed: () async => await changePassword(),
                            child: const Text(
                              ("Change Password"),
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              onPrimary: Colors.white,
                              primary: Colors.indigo,
                            ),
                          ),
                        ),
                         const SizedBox(height: 10),
                        Center(
                          child: ElevatedButton(
                            
                            onPressed: () async {
                            String oldpassword = "";
                            String errorMessage = "";
                            
                            
                              oldpassword = await editField(
                                  "Write the current password", oldpassword);
                              if (oldpassword == "") {
                                _showMessage(
                                    "The user has not been eliminated because the password was not entered");
                              } else {
                                try {
                                  UserCredential authResult =
                                      await user.reauthenticateWithCredential(
                                    EmailAuthProvider.credential(
                                        email: user.email!,
                                        password: oldpassword),
                                  );
                                  await authResult.user!.delete();
                                  
                                } on FirebaseAuthException catch (e) {
                                  switch (e.code.toUpperCase()) {
                                    case "INVALID-EMAIL":
                                      errorMessage =
                                          "Your email address appears to be malformed.";
                                      break;
                                    case "WRONG-PASSWORD":
                                      errorMessage = "Your password is wrong.";
                                      break;
                                    case "USER-NOT-FOUND":
                                      errorMessage =
                                          "User with this email doesn't exist.";
                                      break;
                                    case "USER-DISABLED":
                                      errorMessage =
                                          "User with this email has been disabled.";
                                      break;
                                    case "TOO-MANY-REQUESTS":
                                      errorMessage =
                                          "Too many requests. Try again later.";
                                      break;
                                    case "OPERATION-NOT-ALLOWED":
                                      errorMessage =
                                          "Signing in with Email and Password is not enabled.";
                                      break;
                                    default:
                                      errorMessage =
                                          "An error has happened.\nError code = " +
                                              e.code;
                                  }
                                  _showMessage(errorMessage);
                                }
                              
                            }
                           
                            },
                            child: const Text(
                              ("Delete User"),
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              onPrimary: Colors.white,
                              primary: Colors.indigo,
                            ),
                          
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                            child: ElevatedButton(
                          onPressed: () async {
                            String oldpassword = "";
                            String errorMessage = "";
                            bool mustreload = false;
                            if ((user.email!) != controlleremail.text) {
                              oldpassword = await editField(
                                  "Write the current password", oldpassword);
                              if (oldpassword == "") {
                                _showMessage(
                                    "The update of the email has not been carried out because the password was not entered");
                              } else {
                                try {
                                  UserCredential authResult =
                                      await user.reauthenticateWithCredential(
                                    EmailAuthProvider.credential(
                                        email: user.email!,
                                        password: oldpassword),
                                  );
                                  await authResult.user!
                                      .updateEmail(controlleremail.text);
                                  _showMessage(
                                      "The email has been succesfully changed");
                                  mustreload = true;
                                } on FirebaseAuthException catch (e) {
                                  switch (e.code.toUpperCase()) {
                                    case "INVALID-EMAIL":
                                      errorMessage =
                                          "Your email address appears to be malformed.";
                                      break;
                                    case "WRONG-PASSWORD":
                                      errorMessage = "Your password is wrong.";
                                      break;
                                    case "USER-NOT-FOUND":
                                      errorMessage =
                                          "User with this email doesn't exist.";
                                      break;
                                    case "USER-DISABLED":
                                      errorMessage =
                                          "User with this email has been disabled.";
                                      break;
                                    case "TOO-MANY-REQUESTS":
                                      errorMessage =
                                          "Too many requests. Try again later.";
                                      break;
                                    case "OPERATION-NOT-ALLOWED":
                                      errorMessage =
                                          "Signing in with Email and Password is not enabled.";
                                      break;
                                    default:
                                      errorMessage =
                                          "An error has happened.\nError code = " +
                                              e.code;
                                  }
                                  _showMessage(errorMessage);
                                }
                              }
                            }
                            if ((user.displayName!) !=
                                controllerdisplayname.text) {
                              await user.updateDisplayName(
                                  controllerdisplayname.text);
                              mustreload = true;
                            }
                            if (oldPath!=newPath) {
                             if (oldPath!=""){
                                  await deleteFirestoreStorage(oldPath);
                              }
                              oldPath=await _uploadImage();
                              newPath=oldPath;
                              await user.updatePhotoURL(newPath);
                              mustreload = true;
                            }
                            if (mustreload) {
                              await user.reload();
                              user = FirebaseAuth.instance.currentUser!;
                              _showMessage(
                                  "The changes have been succesfully made");
                              Navigator.of(context).pop(true);
                            } else {
                              _showMessage("No changes have been made");
                            }
                          },
                          child: const Text(
                            ("Save"),
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            onPrimary: Colors.white,
                            primary: Colors.indigo,
                          ),
                        ))
                      ]),
                ),
        ),
      ),
    );
  }
}
