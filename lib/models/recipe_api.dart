class RecipeApi {
  late String label;
  late String image;
  late String uri;

  RecipeApi({required this.label, required this.image, required this.uri});
  factory RecipeApi.fromMap(Map<String, dynamic> parsedJson) {
    return RecipeApi(
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
