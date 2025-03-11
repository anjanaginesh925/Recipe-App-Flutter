import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_recipeapp/screens/recipepage.dart';

class SelectItemsPage extends StatefulWidget {
  const SelectItemsPage({super.key});

  @override
  _SelectItemsPageState createState() => _SelectItemsPageState();
}

class _SelectItemsPageState extends State<SelectItemsPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> items = [];
  Set<int> selectedItems = {}; // Store selected item IDs
  bool isLoading = true;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    final response = await supabase.from('tbl_item').select();
    setState(() {
      items = List<Map<String, dynamic>>.from(response);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredItems = items
        .where((item) => item['item_name']
            .toLowerCase()
            .contains(searchQuery.toLowerCase()))
        .toList();

    return isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: "Search for items",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 620,
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: filteredItems.map((item) {
                          return ChoiceChip(
                        label: Text(
                          item['item_name'],
                          style: TextStyle(
                            color: selectedItems.contains(item['id'])
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        selected: selectedItems.contains(item['id']),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedItems.add(item['id']);
                            } else {
                              selectedItems.remove(item['id']);
                            }
                          });
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        selectedColor:Color.fromRGBO(31, 125, 83, 1),
                        backgroundColor: Colors.grey[200],
                        checkmarkColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        elevation: 2,
                      );
                    }).toList(),
                  ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
ElevatedButton(
  onPressed: () {
   Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeSuggestionPage(
                            availableItemIds: selectedItems.toList(),
                          ),
                        ),
                      );
  },
  style: ElevatedButton.styleFrom(
    minimumSize: Size(300, 50), // Width: 200, Height: 50
    backgroundColor: Color(0xFF1F7D53),
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 4,
  ),
  child: Text(
    "Get Recipe",
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  ),
),

                ],
              ),
            );
  }
}


class RecipeSuggestionPage extends StatefulWidget {
  final List<int> availableItemIds;

  const RecipeSuggestionPage({super.key, required this.availableItemIds});

  @override
  State<RecipeSuggestionPage> createState() => _RecipeSuggestionPageState();
}

class _RecipeSuggestionPageState extends State<RecipeSuggestionPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> recipes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  Future<void> fetchRecipes() async {
  try {
    if (widget.availableItemIds.isEmpty) {
      setState(() {
        recipes = [];
        isLoading = false;
      });
      return;
    }

    // Step 1: Get all recipe-ingredient pairs
    final ingredientResponse = await supabase
        .from('tbl_ingredient')
        .select('reciepe_id, item_id');

    // Step 2: Group required ingredients for each recipe
    Map<int, Set<int>> recipeIngredients = {}; // {recipe_id: {item_id, item_id}}

    for (var row in ingredientResponse) {
      int recipeId = int.parse(row['reciepe_id'].toString());
      int itemId = int.parse(row['item_id'].toString());

      if (!recipeIngredients.containsKey(recipeId)) {
        recipeIngredients[recipeId] = {};
      }
      recipeIngredients[recipeId]!.add(itemId);
    }

    // Step 3: Find recipes where ALL required ingredients exist in selected items
    Set<int> selectedItemsSet = widget.availableItemIds.toSet();
    List<int> validRecipeIds = recipeIngredients.entries
        .where((entry) => selectedItemsSet.containsAll(entry.value)) // Fully matches
        .map((entry) => entry.key)
        .toList();

    if (validRecipeIds.isEmpty) {
      setState(() {
        recipes = [];
        isLoading = false;
      });
      return;
    }

    // Step 4: Fetch all recipes and filter in Flutter
    final recipeResponse = await supabase.from('tbl_recipe').select();

    List<Map<String, dynamic>> filteredRecipes = recipeResponse
        .where((recipe) => validRecipeIds.contains(recipe['id']))
        .toList();

    setState(() {
      recipes = filteredRecipes;
      isLoading = false;
    });
  } catch (e) {
    print('Error fetching recipes: $e');
    setState(() => isLoading = false);
  }
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recipes You Can Cook")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : recipes.isEmpty
              ? const Center(child: Text("No matching recipes found."))
              : ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecipePage(recipeId: recipe['id'].toString(),isEditable: false,),
                          ),
                        );
                      },
                      leading: Image.network(
                        recipe['recipe_photo'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(recipe['recipe_name']),
                      subtitle: Text("Cooking Time: ${recipe['recipe_cookingtime']}"),
                    );
                  },
                ),
    );
  }
}
