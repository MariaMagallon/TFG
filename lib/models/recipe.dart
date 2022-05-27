import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final user = FirebaseAuth.instance.currentUser!;

class Recipe {
  String? id;
  int? isapi;
  late String label;
  late String image;
  String? description;
  String? idapi;
  late String uri;
  late String url;
  late double calories;
  late List<String> ingredientLines = [];
  late List<String> dishType = [];
  late List<String> healthLabels = [];
  late List<String> cuisineType = [];

  Recipe(
      {required this.label,
      required this.image,
      required this.uri,
      required this.url,
      required this.calories,
      required this.ingredientLines,
      required this.dishType,
      required this.healthLabels,
      required this.cuisineType});

  factory Recipe.fromMap(Map<String, dynamic> parsedJson) {
    return Recipe(
        label: parsedJson["label"],
        image: parsedJson["image"],
        uri: parsedJson["uri"],
        url: parsedJson["url"],
        calories: parsedJson["calories"],
        ingredientLines: (parsedJson["ingredientLines"] as List).cast<String>(),
        dishType: (parsedJson["dishType"] as List).cast<String>(),
        healthLabels: (parsedJson["healthLabels"] as List).cast<String>(),
        cuisineType: (parsedJson["cuisineType"] as List).cast<String>());
  }
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

  Recipe.fromFirestore(String _id, Map<String, dynamic> data)
      : id = _id,
        isapi = data['isapi'],
        label = data['label'],
        image = data['image'],
        description = data['description'],
        idapi = data['idapi'],
        uri = data['uri'],
        url = data['url'],
        calories = data['calories'],
        ingredientLines = (data['ingredientLines'] as List).cast<String>(),
        dishType = (data['dishType'] as List).cast<String>(),
        healthLabels = (data['healthLabels'] as List).cast<String>(),
        cuisineType = (data['cuisineType'] as List).cast<String>();

  Map<String, dynamic> toFirestore() => {
        'isapi': isapi,
        'label': label,
        'image': image,
        'description': description,
        'idapi': idapi,
        'uri': uri,
        'url': url,
        'calories': calories,
        'ingredientLines': ingredientLines,
        'dishType': dishType,
        'healthLabels': healthLabels,
        'cuisineType': cuisineType,
      };
}

String edamamId(String uri) {
  return uri.replaceAll(
      "http://www.edamam.com/ontologies/edamam.owl#recipe_", '');
}

Stream<List<Recipe>> loadRecipes(int isapi) {
  final db = FirebaseFirestore.instance;

  final recipes = db.collection("userData").doc(user.uid).collection("recipes");
  return recipes
      .where('isapi', isEqualTo: isapi)
      .snapshots()
      .map((QuerySnapshot<Map<String, dynamic>> query) {
    List<Recipe> result = [];
    for (final docSnap in query.docs) {
      result.add(Recipe.fromFirestore(docSnap.id, docSnap.data()));
    }
    return result;
  });
}

Stream<Recipe> recipeStream(String idrecipe) {
  final db = FirebaseFirestore.instance;
  final recipe = db.doc("/userData/" + user.uid + "/recipes/" + idrecipe);
  return recipe
      .snapshots()
      .map((docSnap) => Recipe.fromFirestore(docSnap.id, docSnap.data()!));
}

Future<Recipe> getFirestoreRecipe(String idrecipe) async {
  final db = FirebaseFirestore.instance;
  final recipe = db.doc("/userData/" + user.uid + "/recipes/" + idrecipe);

  final docSnap = await recipe.get();
  return Recipe.fromFirestore(docSnap.id, docSnap.data()!);
}

Future<void> createRecipe(Recipe recipe) async {
  final db = FirebaseFirestore.instance;
  final docref = await db
      .collection("userData")
      .doc(user.uid)
      .collection("recipes")
      .add(recipe.toFirestore());
  recipe.id = docref.id;
  recipe.id = docref.id.toString();
}
