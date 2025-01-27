import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SearchWidget extends StatefulWidget {
  final Function(String, String) setSearch;

  const SearchWidget({super.key, required this.setSearch});

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  String nameFilter = "";
  String selectedCategory = "All";
  String selectedAlcoholOption = "Both";
  TextEditingController searchController = TextEditingController();
  List<String> categories = [];
  bool firstStart = true;

  @override
  void initState() {
    super.initState();
    if(firstStart){
      clearPreferences();
      firstStart=false;
    }
    fetchCategories();
    loadPreferences();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('https://cocktails.solvro.pl/api/v1/cocktails/categories'));
      if (response.statusCode == HttpStatus.ok) {
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
      nameFilter = prefs.getString('urlFilter') ?? "";
      selectedCategory = prefs.getString('selectedCategory') ?? "All";
      selectedAlcoholOption = prefs.getString('selectedAlcoholOption') ?? "Both";
      searchController.text = nameFilter;
    });
  }
  Future<void> clearPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('urlFilter', '');
    await prefs.setString('selectedCategory', 'All');
    await prefs.setString('selectedAlcoholOption', 'Both');
  }

  Future<void> savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('urlFilter', nameFilter);
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
              decoration: const InputDecoration(labelText: 'Search Cocktails', border: OutlineInputBorder()),
              onChanged: (value) {
                setState(() {
                  nameFilter = value;
                  savePreferences();
                });
                widget.setSearch(nameFilter, "name");
              },
            ),
            const SizedBox(height: 16),
            const Text('Categories:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: selectedCategory,
              onChanged: (String? newValue) {
                setState(() {
                  selectedCategory = newValue!;
                  savePreferences();
                  widget.setSearch(selectedCategory, "category");
                });
              },
              items: categories.map<DropdownMenuItem<String>>((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Alcoholic :',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            RadioListTile<String>(
              title: const Text('Both'),
              value: 'Both',
              groupValue: selectedAlcoholOption,
              onChanged: (value) {
                setState(() {
                  selectedAlcoholOption = value!;
                  savePreferences();
                  widget.setSearch(selectedAlcoholOption, "alcoholic");
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Yes'),
              value: 'true',
              groupValue: selectedAlcoholOption,
              onChanged: (value) {
                setState(() {
                  selectedAlcoholOption = value!;
                  savePreferences();
                  widget.setSearch(selectedAlcoholOption, "alcoholic");
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('No'),
              value: 'false',
              groupValue: selectedAlcoholOption,
              onChanged: (value) {
                setState(() {
                  selectedAlcoholOption = value!;
                  savePreferences();
                  widget.setSearch(selectedAlcoholOption, "alcoholic");
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

String formatSearch(String querry, String type) {
  if (type == "name") {
    if(querry!=''){
      return '&$type=%$querry%';
    }
    else{
      return '';
    }
  } else if (type == "category") {
    if (querry == "All"|| querry == '') {
      return "";
    } else {
      return '&$type=$querry';
    }
  } else if (type == "alcoholic") {
    if (querry == "Both" || querry == '' ) {
      return '';
    } else {
      return '&$type=$querry';
    }
  } else {
    return 'unknown type';
  }
}