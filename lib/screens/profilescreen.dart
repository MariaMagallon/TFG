import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cookmind/globals/globalvariables.dart';
import 'package:cookmind/widgets/editablefield_widget.dart';
import 'package:cookmind/widgets/passwordchange.dart';
import 'package:cookmind/widgets/navigation_drawer_widget.dart';
import 'package:cookmind/globals/storagefunctions.dart';
import 'package:cookmind/widgets/showdialog_widget.dart';

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
  String oldPath = "";
  String newPath = "";

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
    if (user.photoURL != null) {
      oldPath = user.photoURL!;
    } else {
      oldPath = "";
    }
    newPath = oldPath;
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
      return Center(
        child: Stack(
          children: <Widget>[
            CircleAvatar(
              radius: 100,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              child: ClipOval(
                child: SizedBox(
                    width: 180.0,
                    height: 180.0,
                    child: Image.file(
                      File(imagePath!.path),
                      fit: BoxFit.cover,
                    )),
              ),
            ),
          ],
        ),
      );
    } else if ((user.photoURL) != null) {
      return Center(
        child: Stack(
          children: <Widget>[
            CircleAvatar(
              radius: 100,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              child: ClipOval(
                child: SizedBox(
                    width: 180.0,
                    height: 180.0,
                    child: Image.network(
                      user.photoURL!,
                      fit: BoxFit.cover,
                    )),
              ),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: CircleAvatar(
          radius: 100,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          child: const ClipOval(
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
            flexibleSpace:
                Container(decoration: const BoxDecoration(color: Colors.teal)),
            //elevation: 0,
            title: Center(child: Image.asset("assets/logo.png", filterQuality:FilterQuality.high,)),
            actions: [
              Builder(builder: (context) {
                return IconButton(
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                  icon: const Icon(Icons.account_circle_rounded),
                  iconSize: 40.0,
                  color: Colors.white,
                );
              }),
            ],
            leading: IconButton(
              onPressed: () => {
                Navigator.of(context).pop(),
              },
              icon: const Icon(Icons.arrow_back_sharp),
              iconSize: 40.0,
            )),
        endDrawer: const NavigationDrawerWidget(),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: _isloading
              ? const Center(
                  child: CircularProgressIndicator(
                  color: Colors.teal,
                ))
              : SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(
                          height: 20.0,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(15.0),
                              child: Text(
                                "Edit Profile",
                                style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.edit,
                                  color: Colors.teal, size: 30.0),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                            width: 2, color: Colors.amber))),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Transform.translate(
                              offset: const Offset(20, 0),
                              child: widgetShowImage(),
                            ),
                            Transform.translate(
                                offset: const Offset(-50, 50),
                                child: Container(
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 4,
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                    ),
                                    color: Colors.amber,
                                  ),
                                  child: IconButton(
                                    color: Colors.white,
                                    icon: const Icon(Icons.photo_camera),
                                    onPressed: () async {
                                      if (await imagePicker()) {
                                        newPath = imagePath!.path;
                                      }
                                    },
                                  ),
                                )),
                          ],
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 30.0, right: 30.0, bottom: 20.0),
                          child: TextField(
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 22),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide: BorderSide(
                                      color: Colors.grey, width: 0.0),
                                ),
                                labelText: "Nickname",
                                filled: true,
                                fillColor: Color.fromRGBO(255, 255, 255, 0.5),
                                hintStyle: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              controller: controllerdisplayname),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 30.0, right: 30.0, bottom: 20.0),
                          child: TextField(
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 22),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide: BorderSide(
                                      color: Colors.grey, width: 0.0),
                                ),
                                labelText: "Email",
                                filled: true,
                                fillColor: Color.fromRGBO(255, 255, 255, 0.5),
                                hintStyle: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              controller: controlleremail),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async => await changePassword(),
                                  child: const Text('Change Password',
                                      style: TextStyle(
                                          fontSize: 19,
                                          color: Colors.white,
                                          fontFamily: "Heebo",
                                          fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    onPrimary: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                    primary: Colors.teal,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    String oldpassword = "";
                                    String errorMessage = "";

                                    oldpassword = await editField(
                                        "Write the current password",
                                        oldpassword);
                                    if (oldpassword == "") {
                                      await showMyDialog(
                                          context,
                                          "Deleting your account...",
                                          "The user has not been eliminated because the password was not entered");
                                    } else {
                                      try {
                                        UserCredential authResult = await user
                                            .reauthenticateWithCredential(
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
                                            errorMessage =
                                                "Your password is wrong.";
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
                                        await showMyDialog(
                                            context,
                                            "Deleting your account...",
                                            errorMessage);
                                      }
                                    }
                                  },
                                  child: const Text('Delete User',
                                      style: TextStyle(
                                          fontSize: 19,
                                          color: Colors.white,
                                          fontFamily: "Heebo",
                                          fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    onPrimary: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                    primary: Colors.teal,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            children: [
                              Expanded(
                                  child: ElevatedButton(
                                onPressed: () async {
                                  String oldpassword = "";
                                  String errorMessage = "";
                                  bool mustreload = false;
                                  if ((user.email!) != controlleremail.text) {
                                    oldpassword = await editField(
                                        "Write the current password",
                                        oldpassword);
                                    if (oldpassword == "") {
                                      await showMyDialog(
                                          context,
                                          "Changing email...",
                                          "The update of the email has not been carried out because the password was not entered");
                                    } else {
                                      try {
                                        UserCredential authResult = await user
                                            .reauthenticateWithCredential(
                                          EmailAuthProvider.credential(
                                              email: user.email!,
                                              password: oldpassword),
                                        );
                                        await authResult.user!
                                            .updateEmail(controlleremail.text);
                                        await showMyDialog(
                                            context,
                                            "Changing email...",
                                            "The email has been succesfully changed");

                                        mustreload = true;
                                      } on FirebaseAuthException catch (e) {
                                        switch (e.code.toUpperCase()) {
                                          case "INVALID-EMAIL":
                                            errorMessage =
                                                "Your email address appears to be malformed.";
                                            break;
                                          case "WRONG-PASSWORD":
                                            errorMessage =
                                                "Your password is wrong.";
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
                                        await showMyDialog(context,
                                            "Changing email...", errorMessage);
                                      }
                                    }
                                  }
                                  if ((user.displayName!) !=
                                      controllerdisplayname.text) {
                                    await user.updateDisplayName(
                                        controllerdisplayname.text);
                                    mustreload = true;
                                  }
                                  if (oldPath != newPath) {
                                    if (oldPath != "") {
                                      await deleteFirestoreStorage(oldPath);
                                    }
                                    oldPath = await _uploadImage();
                                    newPath = oldPath;
                                    await user.updatePhotoURL(newPath);
                                    mustreload = true;
                                  }
                                  if (mustreload) {
                                    await user.reload();
                                    user = FirebaseAuth.instance.currentUser!;
                                    await showMyDialog(
                                        context,
                                        "Saving changes...",
                                        "The changes have been succesfully changed");

                                    Navigator.of(context).pop(true);
                                  } else {
                                    await showMyDialog(
                                        context,
                                        "Saving changes...",
                                        "No changes have been made");
                                  }
                                },
                                child: const Text('Save',
                                    style: TextStyle(
                                        fontSize: 25,
                                        color: Colors.white,
                                        fontFamily: "Heebo",
                                        fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  onPrimary: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  primary: Colors.teal,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                ),
                              )),
                            ],
                          ),
                        )
                      ]),
                ),
        ),
      ),
    );
  }
}
