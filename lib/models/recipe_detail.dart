import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final user = FirebaseAuth.instance.currentUser!;

class RecipeDetail {
  String? id;
  late String label;
  late String image;
  late String uri;
  late String url;
  late double calories;
  late List<String> ingredientLines = [];
  late List<String> dishType = [];
  late List<String> healthLabels = [];
  late List<String> cuisineType = [];

  RecipeDetail(
      {required this.label,
      required this.image,
      required this.uri,
      required this.calories,
      required this.ingredientLines,
      required this.dishType,
      required this.healthLabels,
      required this.cuisineType,
      required this.url});

  factory RecipeDetail.fromMap(Map<String, dynamic> parsedJson) {
    return RecipeDetail(
      uri: parsedJson["uri"],
      label: parsedJson["label"],
      image: parsedJson["image"],
      calories: parsedJson["calories"],
      ingredientLines: (parsedJson["ingredientLines"] as List).cast<String>(),
      dishType: (parsedJson["dishType"] as List).cast<String>(),
      healthLabels: (parsedJson["healthLabels"] as List).cast<String>(),
      cuisineType: (parsedJson["cuisineType"] as List).cast<String>(),
      url: parsedJson["url"],
    );
  }

  String get edamamId {
    return uri.replaceAll(
        "http://www.edamam.com/ontologies/edamam.owl#recipe_", '');
  }

  RecipeDetail.fromFirestore(String _id, Map<String, dynamic> data)
      : id = _id,
        uri = data['uri'],
        label = data['label'],
        image = data['image'],
        calories = data['calories'],
        ingredientLines = (data['ingredientLines'] as List).cast<String>(),
        dishType = (data['dishType'] as List).cast<String>(),
        healthLabels = (data['healthLabels'] as List).cast<String>(),
        cuisineType = (data['cuisineType'] as List).cast<String>(),
        url = data['url'];

  Map<String, dynamic> toFirestore() => {
        'uri': uri,
        'label': label,
        'image': image,
        'calories': calories,
        'ingredientLines': ingredientLines,
        'dishType': dishType,
        'healthLabels': healthLabels,
        'cuisineType': cuisineType,
        'url': url,
      };
}

Stream<List<RecipeDetail>> loadUserRecipesAPI() {
  final db = FirebaseFirestore.instance;

  final recipes =
      db.collection("userData").doc(user.uid).collection("recipesAPI");
  return recipes.snapshots().map((QuerySnapshot<Map<String, dynamic>> query) {
    List<RecipeDetail> result = [];
    for (final docSnap in query.docs) {
      result.add(RecipeDetail.fromFirestore(docSnap.id, docSnap.data()));
    }
    return result;
  });
}

Future<void> createRecipeAPI(RecipeDetail recipeDetail) async {
  final db = FirebaseFirestore.instance;
  final docref = db
      .collection("userData")
      .doc(user.uid)
      .collection("recipesAPI")
      .doc(recipeDetail.edamamId)
      .set(recipeDetail.toFirestore());
}
