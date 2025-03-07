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
    return Scaffold(
      appBar: AppBar(title: const Text("Select Available Items")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
            shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return CheckboxListTile(
                  title: Text(item['item_name']),
                  value: selectedItems.contains(item['id']),
                  onChanged: (bool? selected) {
                    setState(() {
                      if (selected == true) {
                        selectedItems.add(item['id']);
                      } else {
                        selectedItems.remove(item['id']);
                      }
                    });
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.search),
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
