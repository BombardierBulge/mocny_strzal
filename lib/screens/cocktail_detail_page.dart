import 'package:flutter/material.dart';
import '../classes/cocktails.dart';
import '../classes/ingredients.dart';
import 'package:transparent_image/transparent_image.dart';

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
        title: Text('${widget.cocktail.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: FadeInImage.memoryNetwork(
                  image:widget.cocktail.img_url,
                  placeholder: kTransparentImage,
                  fit: BoxFit.fill,
                  height: MediaQuery.of(context).size.height * 0.5,
                  placeholderErrorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Category: ${widget.cocktail.category}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Alcoholic: ${widget.cocktail.alcoholic ? "Yes" : "No"}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Instructions: ${widget.cocktail.instructions}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                "Ingredients:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              FutureBuilder<List<Ingredients>>(
                future: futureIngredients,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (snapshot.hasData) {
                    var ingredients = snapshot.data!;
                    if (ingredients.isEmpty) {
                      return const Text("No ingredients to display.");
                    }
                    return Column(
                      children: ingredients.map((ingredient) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(216, 216, 216, 1),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: ListTile(
                            title: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: FadeInImage.memoryNetwork(
                                    image: ingredient.imageUrl,
                                    placeholder: kTransparentImage,
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.cover,
                                    imageErrorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    ingredient.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (ingredient.type.isNotEmpty)
                                    Text(
                                      "Type: ${ingredient.type}",
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  Text(
                                    "Alcohol: ${ingredient.alcohol ? "Contains" : "None"}",
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Percentage: ${ingredient.percentage == -1 ? "Unknown" : "${ingredient.percentage}%"}",
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  if (ingredient.description.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        "Description: ${ingredient.description}",
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  if (ingredient.description.isEmpty)
                                    const Text(
                                      "Description: None available",
                                      style: TextStyle(fontSize: 14),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }
                  return const Text("No data available.");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}