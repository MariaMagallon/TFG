import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfg/models/own_recipe.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tfg/models/recipe_detail.dart';

final db = FirebaseFirestore.instance;

class MyRecipes extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser!;
  late OwnRecipe ownRecipe = OwnRecipe(label: "label");

  MyRecipes({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Create Recipe'),
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            _RecipesAPI(),
            /*Text("Title ${ownRecipe.label}"),
            ElevatedButton(
                child: Text("Finish"),
                onPressed: () {
                  createRecipe(ownRecipe);
                } /*async {
                await db
                    .collection("userData")
                    .doc(user.uid)
                    .collection("recipes")
                    .add(ownRecipe.toJson());
              },*/
                ),*/
          ],
        )));
  }
}

class _RecipesAPI extends StatelessWidget {
  const _RecipesAPI({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: loadUserRecipesAPI(),
      builder:
          (BuildContext context, AsyncSnapshot<List<RecipeDetail>> snapshot) {
        if (snapshot.hasError) {
          return ErrorWidget(snapshot.error.toString());
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final _recipesAPI = snapshot.data!;
        return GridView(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            physics: const ClampingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200, mainAxisSpacing: 10.0),
            children: List.generate(_recipesAPI.length, (index) {
              return GridTile(
                  child: GestureDetector(
                      child: RecipeTile(
                          imageurl: _recipesAPI[index].image,
                          title: _recipesAPI[index].label)));
            }));
      },
    );
  }
}

class RecipeTile extends StatefulWidget {
  final String title, imageurl;

  const RecipeTile({Key? key, required this.title, required this.imageurl})
      : super(key: key);

  @override
  _RecipeTileState createState() => _RecipeTileState();
}

class _RecipeTileState extends State<RecipeTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Stack(
        children: <Widget>[
          Image.network(
            widget.imageurl,
            height: 200,
            width: 200,
            fit: BoxFit.cover,
          ),
          Container(
            width: 200,
            alignment: Alignment.bottomLeft,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.5)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.title,
                    style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
