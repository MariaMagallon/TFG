import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfg/globals/globalvariables.dart';
import 'package:firebase_storage/firebase_storage.dart';



class UserProfile{
  String? id;
  late String nickname;
  late String image;
  late String email;

  UserProfile(
      {required this.nickname,
      required this.image,
      required this.email,
      });


  UserProfile.fromFirestore(String _id, Map<String, dynamic> data)
      : id = _id,
        nickname = data['nickname'],
        image = data['image'],
        email= data['email'];

  Map<String, dynamic> toFirestore() => {
        'nickname':nickname,
        'image': image,
        'email': email,
        
  };
}

Future<void> createUserfields(UserProfile userprofile) async {
  final db = FirebaseFirestore.instance;
  final docref = await db
      .collection("userData")
      .doc(user.uid)
      .collection("profile")
      .add(userprofile.toFirestore());
     
  userprofile.id = docref.id;
  userprofile.id = docref.id.toString();
}

Future<void> deleteFirestoreStorage(String imageref) async {
  final storageReference = FirebaseStorage.instance.ref();

  String filePath = imageref.replaceAll(
      "https://firebasestorage.googleapis.com/v0/b/tfg-database-68ae7.appspot.com/o/",
      '');
  filePath = filePath.replaceAll(RegExp(r'%2F'), '/');

  filePath = filePath.replaceAll(RegExp(r'[?alt].*'), '');
 

  storageReference
      .child(filePath)
      .delete()
      .then((_) => print('Successfully deleted $filePath storage item'));
}

Future<void> updateUserProfile(UserProfile userprofile ) async {
  final db = FirebaseFirestore.instance;
  db.doc("/userData/" + user.uid + "/profile/" + userprofile.id!).update(userprofile.toFirestore());
}