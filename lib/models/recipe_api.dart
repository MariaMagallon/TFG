class Recipe {
  late String label;
  late String image;
  late String uri;

  Recipe({required this.label, required this.image, required this.uri});
  factory Recipe.fromMap(Map<String, dynamic> parsedJson) {
    return Recipe(
      uri: parsedJson["uri"],
      label: parsedJson["label"],
      image: parsedJson["image"],
    );
  }
}

String edamamId(String uri) {
  return uri.replaceAll(
      "http://www.edamam.com/ontologies/edamam.owl#recipe_", '');
}
