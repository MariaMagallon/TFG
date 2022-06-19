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
  

  
  
  @override
  void initState() {
    super.initState();
   
    controllerOldpass = TextEditingController();
    controllerNewpass = TextEditingController();
    controllerConfpass = TextEditingController();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text("Change the password"),
        content: Container(
          height: 250,
         
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
                        border: OutlineInputBorder(),
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
              TextField(
                controller: controllerNewpass,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "New Password",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controllerConfpass,
                obscureText: true,              
                decoration: const InputDecoration(
                  labelText: "Confirm Password",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        
        actions: [
          ElevatedButton(
            child: const Text('Done'),
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
          )
        ],
      );
}