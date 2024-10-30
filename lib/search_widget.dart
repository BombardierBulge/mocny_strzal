import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SearchWidget extends StatefulWidget {
  final Function(String, String) setSearch;

  SearchWidget({required this.setSearch});

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  String urlFilter = "";
  String selectedCategory = "All";
  String selectedAlcoholOption = "Both";
  TextEditingController searchController = TextEditingController();
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    fetchCategories();
    loadPreferences();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('https://cocktails.solvro.pl/api/v1/cocktails/categories'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        setState(() {
          categories = ["All"];
          categories.addAll(data.map((category) => category.toString()).toSet().toList());
        });
      }
    } catch (e) {
      print("Error loading categories: $e");
    }
  }

  Future<void> loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      urlFilter = prefs.getString('urlFilter') ?? "";
      selectedCategory = prefs.getString('selectedCategory') ?? "All";
      selectedAlcoholOption = prefs.getString('selectedAlcoholOption') ?? "Both";
      searchController.text = urlFilter;
    });
  }

  Future<void> savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('urlFilter', urlFilter);
    await prefs.setString('selectedCategory', selectedCategory);
    await prefs.setString('selectedAlcoholOption', selectedAlcoholOption);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
        padding: const EdgeInsets.all(16.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    TextField(
    controller: searchController,
    decoration: InputDecoration(labelText: 'Search Cocktails', border: OutlineInputBorder()),
    onChanged: (value) {
    setState(() {
    urlFilter = value;
    savePreferences();
    });
    widget.setSearch(urlFilter, "name");
    },
    ),
    SizedBox(height: 16),
    Text('Categories:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    DropdownButton<String>(
    value: selectedCategory,
    onChanged: (String? newValue) {
    setState(() {
    selectedCategory = newValue!;
    savePreferences();
    widget.setSearch(selectedCategory, "category");
    });
