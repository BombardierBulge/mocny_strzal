import 'package:flutter/material.dart';
import '../models/cocktails.dart';
import '../models/ingredients.dart';
import '../services/api_service.dart';

class CocktailDetailPage extends StatefulWidget {
  final Cocktails cocktail;

  const CocktailDetailPage({required this.cocktail});

  @override
  _CocktailDetailPageState createState() => _CocktailDetailPageState();
}

class _CocktailDetailPageState extends State<CocktailDetailPage> {
  late Future<List<Ingredients>> futureIngredients;

  @override
  void initState() {
    super.initState();
    futureIngredients = fetchIngredients(widget.cocktail.id.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: Text(widget.cocktail.name),
      ),
      body: Column(
        children: [
          Image.network(widget.cocktail.img_url),
          FutureBuilder<List<Ingredients>>(
            future: futureIngredients,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Błąd: ${snapshot.error}"));
              } else if (snapshot.hasData) {
                return Column(
                  children: snapshot.data!.map((ingredient) => ListTile(
                    title: Text(ingredient.name),
                    leading: Image.network(ingredient.imageUrl),
                  )).toList(),
                );
              }
              return const Text("No data");
            },
          )
        ],
      ),
    );
  }
}