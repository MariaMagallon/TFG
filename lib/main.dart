import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tfg/widgets/auth_gate.dart';
// Import the generated file
import 'firebase_options.dart';
import 'package:tfg/screens/searchscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AuthGate(app: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SearchScreen(),
    );
  }
}
