import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


final user = FirebaseAuth.instance.currentUser!;

class OwnRecipe {
  String? id;
  late String label, image, description;

  OwnRecipe({required this.label, required this.image, required this.description});
  Map<String, dynamic> toJson() => {
        'label': label,
        'image':image,
        'description':description
        
      };

  OwnRecipe.fromFirestore(this.id, Map<String, dynamic> data)
      : 
        label = data['label'],
        image= data['image'];

  Map<String, dynamic> toFirestore() => {
        'label': label,
        'image':image,
        'description':description
      };
}

Stream<List<OwnRecipe>> loadUserRecipes() {
  final db = FirebaseFirestore.instance;

  final recipes = db.collection("userData").doc(user.uid).collection("recipes");
  return recipes.snapshots().map((QuerySnapshot<Map<String, dynamic>> query) {
    List<OwnRecipe> result = [];
    for (final docSnap in query.docs) {
      result.add(OwnRecipe.fromFirestore(docSnap.id, docSnap.data()));
    }
    return result;
  });
}


Future<void> createRecipe(OwnRecipe ownRecipe) async {
  final db = FirebaseFirestore.instance;
  final docref = await db.collection("userData")
      .doc(user.uid)
      .collection("recipes")
      .add(ownRecipe.toFirestore());
  ownRecipe.id = docref.id;
  ownRecipe.id = docref.id.toString();
}