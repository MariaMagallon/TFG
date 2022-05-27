import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final user = FirebaseAuth.instance.currentUser!;

class OwnRecipe {
  String? id;
  late String label, image, description;
  late double calories;
  late List<String> ingredientLines = [];
  late List<String> dishType = [];
  late List<String> healthLabels = [];
  late List<String> cuisineType = [];

  OwnRecipe({
    required this.label,
    required this.image,
    required this.description,
    required this.calories,
    required this.ingredientLines,
    required this.dishType,
    required this.healthLabels,
    required this.cuisineType,
  });
  Map<String, dynamic> toJson() => {
        'label': label,
        'image': image,
        'description': description,
        'calories': calories,
        'ingredientLines': ingredientLines,
        'dishType': dishType,
        'healthLabels': healthLabels,
        'cuisineType': cuisineType,
      };

  OwnRecipe.fromFirestore(this.id, Map<String, dynamic> data)
      : label = data['label'],
        image = data['image'],
        calories = data['calories'],
        ingredientLines = (data['ingredientLines'] as List).cast<String>(),
        dishType = (data['dishType'] as List).cast<String>(),
        healthLabels = (data['healthLabels'] as List).cast<String>(),
        cuisineType = (data['cuisineType'] as List).cast<String>();

  Map<String, dynamic> toFirestore() => {
        'label': label,
        'image': image,
        'description': description,
        'calories': calories,
        'ingredientLines': ingredientLines,
        'dishType': dishType,
        'healthLabels': healthLabels,
        'cuisineType': cuisineType,
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
  final docref = await db
      .collection("userData")
      .doc(user.uid)
      .collection("recipes")
      .add(ownRecipe.toFirestore());
  ownRecipe.id = docref.id;
  ownRecipe.id = docref.id.toString();
}
