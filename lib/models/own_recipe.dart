import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final user = FirebaseAuth.instance.currentUser!;

class OwnRecipe {
  String? id;
  late String label;

  OwnRecipe({required this.label});
  Map<String, dynamic> toJson() => {
        'label': label,
      };

  OwnRecipe.fromFirestore(String _id, Map<String, dynamic> data)
      : id = _id,
        label = data['label'];

  Map<String, dynamic> toFirestore() => {
        'label': label,
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

void createRecipe(OwnRecipe ownRecipe) async {
  final db = FirebaseFirestore.instance;
  final docref = db
      .collection("userData")
      .doc(user.uid)
      .collection("recipes")
      .add(ownRecipe.toFirestore());
}
