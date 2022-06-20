import 'package:firebase_storage/firebase_storage.dart';
import 'dart:core';
Future<void> deleteFirestoreStorage(String imageref) async {
  final storageReference = FirebaseStorage.instance.ref();

  String filePath = imageref.replaceAll(
      "https://firebasestorage.googleapis.com/v0/b/tfg-database-68ae7.appspot.com/o/",
      '');
  filePath = filePath.replaceAll(RegExp(r'%2F'), '/');

  filePath = filePath.replaceAll(RegExp(r'[?].*'), '');
 

  storageReference
      .child(filePath)
      .delete()
      .then((_) => print('Successfully deleted $filePath storage item'));
}