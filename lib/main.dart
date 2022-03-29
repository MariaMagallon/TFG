import 'package:flutter/material.dart';
import 'package:tfg/screens/detailscreen.dart';
import 'package:tfg/screens/searchscreen.dart';
import 'package:tfg/screens/detailscreen_state.dart';


void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SearchScreen(),
    );
  }
}

