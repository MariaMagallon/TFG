class RecipeApi{
 late String label;
 late String image;
 
 

  RecipeApi({required this.label, required this.image});
  factory RecipeApi.fromMap(Map<String,dynamic>parsedJson){
    return RecipeApi(
      
      label: parsedJson ["label"],
      image: parsedJson["image"],
      
    );
  }
}