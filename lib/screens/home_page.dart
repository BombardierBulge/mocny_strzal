import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'cocktail_detail_page.dart';
import 'search_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cocktails.dart';
import 'package:transparent_image/transparent_image.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Cocktails> cocktails = [];
  bool isLoading = false;
  int currentPage = 1;
  String nameFilter = '';
  String categoryFilter = '';
  String alcoholicFilter = '';
  String urlFilter = '';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchData();
    _scrollController.addListener(_scrollListener);
  }




  Future<void> fetchData() async {
    setState(() => isLoading = true);
    await loadPreferences();
    urlFilter = formatSearch(nameFilter, "name") + formatSearch(categoryFilter, "category") + formatSearch(alcoholicFilter, "alcoholic");//'${nameFilter!=''?"&"+nameFilter:""}&${categoryFilter!=''?"&"+categoryFilter:""}&${alcoholicFilter!=''?"&"+nameFilter:""}';
    var endpointURL = "https://cocktails.solvro.pl/api/v1/cocktails?page=$currentPage$urlFilter";
    var url = Uri.parse(endpointURL);
    var response = await http.get(url);

    if (response.statusCode == HttpStatus.ok) {
      var jsonResponse = json.decode(response.body)["data"] as List<dynamic>;
      List<Cocktails> fetchedCocktails = jsonResponse.map((cocktail) => Cocktails.fromMap(cocktail)).toList();
      setState(() {
        for (var cocktail in fetchedCocktails) {
          if (!cocktails.any((c) => c.id == cocktail.id)) {
            cocktails.add(cocktail);
          }
        }
        isLoading = false;
        currentPage++;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !isLoading) {
      fetchData();
    }
  }

  Future<void> loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      nameFilter = prefs.getString('urlFilter') ?? "";
      categoryFilter = prefs.getString('selectedCategory') ?? "All";
      alcoholicFilter = prefs.getString('selectedAlcoholOption') ?? "Both";
    });
  }

  void setSearch(String filter, String type) {
    setState(() {
      if (type == "name") nameFilter = filter;
      if (type == "category") categoryFilter = filter;
      if (type == "alcoholic") alcoholicFilter = filter;
      cocktails.clear();
      currentPage = 1;
      fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title:
          const  Text("Cocktails ",style: TextStyle(fontWeight: FontWeight.w500),),
          backgroundColor: Colors.pinkAccent,
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              ),
            ),
          ],
        ),
        endDrawer: Drawer(
          child: SearchWidget(
              setSearch:
              setSearch,), // Przekazanie funkcji setSearch do SearchWidget
        ),
        body: cocktails.isEmpty && isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
          controller: _scrollController,
          itemCount: cocktails.length + 1,
          itemBuilder: (context, index) {
            if (index < cocktails.length) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(216, 216, 216, 216),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  width: 100, // szerokość obrazka
                  height: MediaQuery.of(context).size.height * 0.10, // wysokość obrazka
                  child: Center(
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CocktailDetailPage(
                                cocktail: cocktails[index]),
                          ),
                        );
                      },
                      title: Text(cocktails[index].name,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500)),
                      leading: FadeInImage.memoryNetwork(
                        image: cocktails[index].img_url.toString(), // link obrazka
                          placeholder: kTransparentImage,
                        height:MediaQuery.of(context).size.height * 0.2,
                        fit: BoxFit.cover, // dopasowanie obrazka
                        imageErrorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons
                            .broken_image), // ikona  w razie błędu
                      ),
                    ),
                  ),
                ),
              );
            } else if (isLoading) {
              return const Center(
                  child:
                  CircularProgressIndicator()); // Wskaźnik ładowania na końcu listy
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}