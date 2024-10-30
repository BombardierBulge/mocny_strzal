import 'package:http/http.dart' as http;
import 'dart:convert';

class Ingredients {
  int id = 0;
  String name = '';
  String description = '';
  bool alcohol = false;
  String type = '';
  int percentage = 0;
  String imageUrl = '';
  String measure = '';

  Ingredients(this.id, this.name, this.description, this.alcohol, this.type, this.percentage, this.imageUrl, this.measure);

  factory Ingredients.fromMap(Map<String, dynamic> json) {
    return Ingredients(
      json['id'],
      json['name'] ?? "",
      json['description'] ?? "",
      json['alcohol'],
      json['type'] ?? "",
      json['percentage'] ?? -1,
      json['imageUrl'] ?? "",
      json['measure'] ?? "",
    );
  }
}

Future<List<Ingredients>> fetchIngredients(String id) async {
  List<Ingredients> ingredients = [];
  var endpointURL = "https://cocktails.solvro.pl/api/v1/cocktails/$id";
  var url = Uri.parse(endpointURL);
  var response = await http.get(url);

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body)["data"]["ingredients"] as List<dynamic>;
    ingredients = jsonResponse.map((ingredient) => Ingredients.fromMap(ingredient)).toList();
  }
  return ingredients;
}