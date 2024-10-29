import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(HomePage());
}

class Ingredients {
  int id = 0;
  String name = '';
  String description = '';
  bool alcohol = false;
  String type = '';
  int percentage = 0;
  String imageUrl = '';
  String measure = '';

  //"createdAt": "2024-10-05 18:05:47",
  //"updatedAt": "2024-10-05 18:05:47"
  Ingredients(
    this.id,
    this.name,
    this.description,
    this.alcohol,
    this.type,
    this.percentage,
    this.imageUrl,
    this.measure,
    //this.createdAt,
    //this.updatedAt,
  );

  factory Ingredients.fromMap(
    Map<String, dynamic> json,
  ) {
    return Ingredients(
      json['id'],
      json['name'] == null ? "" : json['name'],
      json['description'] == null ? "" : json['description'],
      json['alcohol'],
      json['type'] == null ? "" : json['type'],
      json['percentage'] == null ? -1 : json['percentage'],
      // Użycie poprawnego klucza dla URL-a obrazu
      json['imageUrl'] == null ? "" : json['imageUrl'],
      json['measure'] == null ? "" : json['measure'],
      //json['createdAt'],
      //json['updatedAt']
    );
  }
}

Future<List<Ingredients>> fetchIngredients(String id) async {
  List<Ingredients> ingredients = [];
  var endpointURL = "https://cocktails.solvro.pl/api/v1/cocktails/$id";
  var url = Uri.parse(endpointURL);
  var response = await http.get(url);

  if (response.statusCode == 200) {
    var jsonResponse =
        json.decode(response.body)["data"]["ingredients"] as List<dynamic>;
    for (var ingredient in jsonResponse) {
      ingredients.add(Ingredients.fromMap(ingredient));
    }
  }
  return ingredients;
}

String formatSearch(String querry, String type) {
  if (type == "name") {
    return '&${type}=%${querry}%';
  } else if (type == "category") {
    if (querry == "All") {
      return "";
    } else {
      return '&${type}=${querry}';
    }
  } else if (type == "alcoholic") {
    if (querry == "Both") {
      return '';
    } else {
      return '&${type}=${querry}';
    }
  } else {
    return 'unknown type';
  }
}

class Cocktails {
  int id = 0;
  String name = '';
  String category = '';
  String glass = '';
  String instructions = '';
  String img_url = '';
  bool alcoholic = false;
  //DateTime createdAt= DateTime.now();
  //DateTime updatedAt= DateTime.now();
  Cocktails(
    this.id,
    this.name,
    this.category,
    this.glass,
    this.instructions,
    this.img_url,
    this.alcoholic,
    //this.createdAt,
    //this.updatedAt,
  );
  factory Cocktails.fromMap(
    Map<String, dynamic> json,
  ) {
    return Cocktails(
      json['id'],
      json['name'],
      json['category'],
      json['glass'],
      json['instructions'],
      json['imageUrl'],
      json['alcoholic'],
      //json['createdAt'],
      //json['updatedAt']
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Cocktails> cocktails = [];
  bool isLoading = false;
  int currentPage = 1; // page number
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
    setState(() {
      isLoading = true;
    });
    urlFilter = '${nameFilter}${categoryFilter}${alcoholicFilter}';
    var endpointURL =
        "https://cocktails.solvro.pl/api/v1/cocktails?page=${currentPage}${urlFilter}";
    var url = Uri.parse(endpointURL);
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body)["data"] as List<dynamic>;
      List<Cocktails> fetchedCocktails =
          jsonResponse.map((cocktail) => Cocktails.fromMap(cocktail)).toList();

      setState(() {
        fetchedCocktails.forEach((cocktail) {
          if (!cocktails.any((c) => c.id == cocktail.id)) {
            cocktails.add(cocktail);
          }
        });
        isLoading = false;
        currentPage++;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isLoading) {
      fetchData();
    }
  }

  void setSearch(String filter, String type) {
    setState(() {
      if (type == "name") {
        nameFilter = filter;
      } else if (type == "category") {
        categoryFilter = filter;
      } else if (type == "alcoholic") {
        alcoholicFilter = filter;
      }
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
            const  Text("Koktaile ",style: TextStyle(fontWeight: FontWeight.w500),),
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
                  setSearch), // Przekazanie funkcji setSearch do SearchWidget
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
                        height: MediaQuery.of(context).size.height * 0.13, // wysokość obrazka
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
                            leading: Image.network(
                              cocktails[index].img_url, // link obrazka
                              height:MediaQuery.of(context).size.height * 0.2,
                              fit: BoxFit.cover, // dopasowanie obrazka
                              errorBuilder: (context, error, stackTrace) =>
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
              Center(child: Image.network(
                  widget.cocktail.img_url,
                fit: BoxFit.fill,
                height:MediaQuery.of(context).size.height * 0.5 ,),), // Wyświetlenie obrazu koktajlu z linku
              const SizedBox(height: 16),
              Text(
                'Category: ${widget.cocktail.category}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Alcoholic: ${widget.cocktail.alcoholic ? "Yes" : "No"}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    return Center(child: Text("Błąd: ${snapshot.error}"));
                  } else if (snapshot.hasData) {
                    var ingredients = snapshot.data!;
                    if (ingredients.isEmpty) {
                      return const Text("Brak danych do wyświetlenia");
                    }
                    return Column(
                      children: ingredients.map((ingredient) {
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(216, 216, 216, 216),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: ListTile(
                            title: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(0.2),
                                  child: Image.network(
                                    ingredient.imageUrl, // link obrazka
                                    height: 100,
                                    width: 100,
                                    fit:
                                        BoxFit.scaleDown, // dopasowanie obrazka
                                    errorBuilder: (context, error,
                                            stackTrace) =>
                                        const Icon(Icons
                                            .broken_image), // ikona zastępcza w razie błędu
                                  ),
                                ),
                                Text(
                                  ingredient.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Title(
                                        color: Colors.black,
                                        child: Text(
                                            ingredient.type != ''
                                                ? "Type : ${ingredient.type}"
                                                : "Type : None",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    Title(
                                        color: Colors.black,
                                        child: Text(
                                            ingredient.alcohol
                                                ? "Alcohol : Contain"
                                                : "Alcohol : Exclude",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    Title(
                                        color: Colors.black,
                                        child: Text(
                                            ingredient.percentage != 0
                                                ? (ingredient.percentage == -1
                                                    ? "Percentage : Unknown"
                                                    : "Percentage : ${ingredient.percentage}%")
                                                : "Percentage : None",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    Title(
                                        color: Colors.black,
                                        child: Text(
                                            ingredient.description != ''
                                                ? "Description : "
                                                : "There's no Description",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    Text(ingredient.description == ''
                                        ? ""
                                        : ingredient.description),
                                  ]),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }
                  return const Text("No data");
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}


class SearchWidget extends StatefulWidget {
  final Function(String, String) setSearch;

  SearchWidget({required this.setSearch});

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}



class _SearchWidgetState extends State<SearchWidget> {
  String urlFilter = "";
  String selectedCategory = "All"; // Domyślna wartość kategorii
  String selectedAlcoholOption = "Both"; // Domyślna wartość  alkoholu
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
      } else {
        throw Exception('Failed to load categories');
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
              decoration: InputDecoration(
                labelText: 'Search Cocktails',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  urlFilter = value;
                  savePreferences();
                });
                widget.setSearch(formatSearch(urlFilter, "name"), "name");
              },
            ),
            SizedBox(height: 16),
            Text(
              'Categories :',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            DropdownButton<String>(
              value: selectedCategory,
              onChanged: (String? newValue) {
                setState(() {
                  selectedCategory = newValue!;
                  savePreferences();
                  widget.setSearch(formatSearch(selectedCategory, "category"), "category");
                });
              },
              items: categories.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Text(
              'Alcoholic :',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            RadioListTile<String>(
              title: const Text('Both'),
              value: 'Both',
              groupValue: selectedAlcoholOption,
              onChanged: (value) {
                setState(() {
                  selectedAlcoholOption = value!;
                  savePreferences();
                  widget.setSearch(formatSearch(selectedAlcoholOption, "alcoholic"), "alcoholic");
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
                  widget.setSearch(formatSearch(selectedAlcoholOption, "alcoholic"), "alcoholic");
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
                  widget.setSearch(formatSearch(selectedAlcoholOption, "alcoholic"), "alcoholic");
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
