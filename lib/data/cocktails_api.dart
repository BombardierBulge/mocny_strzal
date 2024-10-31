import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/ingredients.dart';
const _url="https://cocktails.solvro.pl/api/v1/cocktails/";


Future<List<Ingredients>> fetchIngredients(String id) async {
  List<Ingredients> ingredients = [];
  var endpointURL = "$_url$id";
  var url = Uri.parse(endpointURL);
  var response = await http.get(url);

  if (response.statusCode == HttpStatus.ok) {
    var jsonResponse = json.decode(response.body)["data"]["ingredients"] as List<dynamic>;
    ingredients = jsonResponse.map((ingredient) => Ingredients.fromMap(ingredient)).toList();
  }
  return ingredients;
}