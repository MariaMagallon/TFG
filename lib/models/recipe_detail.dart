
class RecipeDetail{
 late String label;
 late String image;
 late String uri;
 late String url;
 late double calories;
 late List <String> ingredientLines=[];
 late List <String> dishType=[];
 late List <String> healthLabels=[];
 late List <String> cuisineType=[];
 
 
 

  RecipeDetail({required this.label, required this.image,required this.uri,required this.calories, required this.ingredientLines, required this.dishType, required this.healthLabels, required this.cuisineType, required this.url});
  factory RecipeDetail.fromMap(Map<String,dynamic>parsedJson){
    return RecipeDetail(
      uri: parsedJson ["uri"],
      label: parsedJson ["label"],
      image: parsedJson["image"],
      calories: parsedJson["calories"],
      ingredientLines: (parsedJson["ingredientLines"] as List).cast<String>(),
      dishType: (parsedJson["dishType"] as List).cast<String>(),
      healthLabels: (parsedJson["healthLabels"] as List).cast<String>(),
      cuisineType: (parsedJson["cuisineType"] as List).cast<String>(),
      url: parsedJson ["url"],
    );
  }
}