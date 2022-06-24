import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tfg/globals/globalvariables.dart';
import 'package:tfg/widgets/showdialog_widget.dart';
Future<T?> showTextDialogPassword<T>(
  BuildContext context) =>
    showDialog<T>(
      context: context,
      builder: (context) => const TextDialogWidget(
        
      ),
    );

class TextDialogWidget extends StatefulWidget {
  

  const TextDialogWidget({
    Key? key,

  }) : super(key: key);

  @override
  _TextDialogWidgetState createState() => _TextDialogWidgetState();
}

class _TextDialogWidgetState extends State<TextDialogWidget> {
  late TextEditingController controllerOldpass;
  late TextEditingController controllerNewpass;
  late TextEditingController controllerConfpass;
  bool oscuroOld=true;
  bool oscuroNew=true;
  bool oscuroConf=true;
  

  
  
  @override
  void initState() {
    super.initState();
   
    controllerOldpass = TextEditingController();
    controllerNewpass = TextEditingController();
    controllerConfpass = TextEditingController();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Center(child:  Text("Change the password".toUpperCase(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),)),
        content: SizedBox(
          height: 220,
         
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: controllerOldpass,
                      obscureText: oscuroOld,
                      
                      decoration: const InputDecoration(
                      
                        labelText: "Current Password",
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(color: Colors.grey, width: 0.0),
                        ),
                      ),
                    ),
                  ),
                  
                  IconButton(
                    onPressed: () {
                      setState(() {
                        oscuroOld=!oscuroOld;
                      });
                    },
                    icon: const Icon(Icons.remove_red_eye),
                    iconSize: 20.0,
                  )
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: controllerNewpass,
                      obscureText: oscuroNew,
                      
                      decoration: const InputDecoration(
                      
                        labelText: "New Password",
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(color: Colors.grey, width: 0.0),
                          ),
                      ),
                    ),
                  ),
                  
                  IconButton(
                    onPressed: () {
                      setState(() {
                        oscuroNew=!oscuroNew;
                      });
                    },
                    icon: const Icon(Icons.remove_red_eye),
                    iconSize: 20.0,
                  )
                ],
              ),
              const SizedBox(height: 20),
             Row(
                children: [
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: controllerConfpass,
                      obscureText: oscuroConf,
                      
                      decoration: const InputDecoration(
                      
                        labelText: "Confirm Password",
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(color: Colors.grey, width: 0.0),
                        ),
                      ),
                    ),
                  ),
                  
                  IconButton(
                    onPressed: () {
                      setState(() {
                        oscuroConf=!oscuroConf;
                      });
                    },
                    icon: const Icon(Icons.remove_red_eye),
                    iconSize: 20.0,
                  )
                ],
              ),
            ],
          ),
        ),
        
        actions: [
          Center(
            child: ElevatedButton(
              child: const Text(
              'Done', 
              style: TextStyle( 
                fontSize: 19,
                color: Colors.white,
                fontFamily: "Heebo",
                fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
            onPrimary: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            
            primary: Colors.teal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)),
        ),
              onPressed: () async {
                bool isgood=true;
                String errorMessage="";
                
                if(controllerOldpass.text==""){
                await showMyDialog(context, "Changing Password...", "The Current password is empty");
                  
                  isgood=false;
                }else if(controllerNewpass.text==""){
                  await showMyDialog(context, "Changing Password...", "The New password is empty");
                  
                  isgood=false;
                }else if(controllerConfpass.text==""){
                  await showMyDialog(context, "Changing Password...", "The Confirm password is empty");
                  
                  isgood=false;
                }else if (controllerConfpass.text!=controllerNewpass.text){
                  await showMyDialog(context, "Changing Password...", "The new password and its confirmation are not the same");
                  
                  isgood=false;
                }

                if (isgood){
                  try {
                    UserCredential authResult =
                        await user.reauthenticateWithCredential(
                      EmailAuthProvider.credential(
                          email: user.email!,
                          password: controllerOldpass.text),
                    );
                    await authResult.user!.updatePassword(controllerNewpass.text);
                    await showMyDialog(context, "Changing Password...", "The password has been succesfully changed");
                    Navigator.of(context).pop();

                  } on FirebaseAuthException catch (e) {
                    switch (e.code.toUpperCase()) {
                      case "INVALID-EMAIL":
                        errorMessage = "Your email address appears to be malformed.";
                        break;
                      case "WEAK-PASSWORD":
                        errorMessage = "The password must contain at least 6 characters.";
                        break;
                      case "WRONG-PASSWORD":
                        errorMessage = "Your current password is wrong.";
                        break;
                      case "USER-NOT-FOUND":
                        errorMessage ="User with this email doesn't exist.";
                        break;
                      case "USER-DISABLED":
                        errorMessage ="User with this email has been disabled.";
                        break;
                      case "TOO-MANY-REQUESTS":
                        errorMessage ="Too many requests. Try again later.";
                        break;
                      case "OPERATION-NOT-ALLOWED":
                        errorMessage = "Signing in with Email and Password is not enabled.";
                        break;
                      default:
                        errorMessage ="An error has happened.\nError code = "+e.code;
                    }
                    await showMyDialog(context, "Changing Password...", errorMessage);
                    
                    }
                 
                
                }
                
              } ,
            ),
          ),
          const SizedBox(
            height: 10,
          )
        ],
      );
}