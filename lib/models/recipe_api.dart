class RecipeApi{
 late String label;
 late String image;
 late String uri;
 
 

  RecipeApi({required this.label, required this.image,required this.uri});
  factory RecipeApi.fromMap(Map<String,dynamic>parsedJson){
    return RecipeApi(
      uri: parsedJson ["uri"],
      label: parsedJson ["label"],
      image: parsedJson["image"],
      
    );
  }
}