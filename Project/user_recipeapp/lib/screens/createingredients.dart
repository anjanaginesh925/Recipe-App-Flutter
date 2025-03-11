import 'package:flutter/material.dart';
import 'package:user_recipeapp/main.dart';
import 'package:user_recipeapp/screens/createinstructions.dart';

class Ingredients extends StatefulWidget {
  final String recipieId;
  const Ingredients({super.key, required this.recipieId,});

  @override
  State<Ingredients> createState() => _IngredientsState();
}

class _IngredientsState extends State<Ingredients> {
  final TextEditingController _quantityController = TextEditingController();
  String? _selectedIngredient;
  String? _selectedUnit; // To store selected measurement unit
  List<Map<String, dynamic>> items = [];

  // List of common measurement units
  final List<String> _measurementUnits = [
    'tsp', // teaspoon
    'tbsp', // tablespoon
    'cup',

    'g', // grams
    'kg', // kilograms
    'ml', // milliliters
    'l', // liters
    'nos', // number of items
    'bag',
    'pinch',
    'dash', // a small amount, usually for spices
    'drop', // for liquids like lemon juice or essence
    'clove', // for garlic or spices like cloves
    'pod', // for cardamom, tamarind
    'stick', // for cinnamon, butter
    'handful', // a rough quantity for leafy greens, nuts
    'slice', // for fruits, vegetables, or cheese
    'piece', // generic unit for items like ginger, paneer, etc.
    'bunch', // for coriander, curry leaves, or mint
    'sprig', // for herbs like curry leaves, mint
    'block', // for paneer, butter
    'liter', // alternate for 'l'
    'gram', // alternate for 'g'

    'small bowl', // common in Indian households
    'big bowl', // for larger quantities
    'heap', // used for heaped spoonfuls of ingredients
    'sheet', // for pastry, phyllo dough

    'can', // for condensed milk, coconut milk
    'bottle', // for sauces, oil
    'packet', // for pre-packed ingredients like yeast, spices
    'scoop', // for ice cream, ghee, protein powder
  ];

  Future<void> insertIngredients() async {
    try {
      if (_selectedIngredient != null && _selectedUnit != null) {
        String quantity = _quantityController.text;

        await supabase.from('tbl_ingredient').insert({
          'item_id': _selectedIngredient,
          'ingredient_quantity':quantity,
          'reciepe_id': widget.recipieId,
          'ingredient_unit': _selectedUnit,
        });
        _quantityController.clear();

        fetchIngredients();
        setState(() {
          _selectedIngredient = null;
          _selectedUnit = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Failed. Please Try Again!!",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));
      print("ERROR ADDING RECIPE: $e");
    }
  }

  Future<void> fetchItems() async {
    try {
      final response = await supabase.from('tbl_item').select();
      setState(() {
        items = response;
      });
    } catch (e) {
      print("ERROR FETCHING INGREDIENTS: $e");
    }
  }
  Future<void> deleteIngredient(int ingredientId) async {
  try {
    await supabase.from('tbl_ingredient').delete().match({'id': ingredientId});
    fetchIngredients(); // Refresh the list after deletion
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Failed to delete. Try again!"),
        backgroundColor: Colors.red,
      ),
    );
    print("ERROR DELETING INGREDIENT: $e");
  }
}

  List<Map<String, dynamic>> ingredients = [];

  Future<void> fetchIngredients() async {
    try {
      final response = await supabase
          .from('tbl_ingredient')
          .select("*, tbl_item(*)")
          .eq('reciepe_id', widget.recipieId);
      setState(() {
        ingredients = response;
      });
    } catch (e) {
      print("ERROR FETCHING INGREDIENTS: $e");
    }
  }



  @override
  void initState() {
    super.initState();
    fetchItems();
    fetchIngredients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Find Best Recipes for Cooking",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedIngredient,
              decoration: const InputDecoration(
                labelText: "Ingredient",
                border: OutlineInputBorder(),
              ),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item['id']?.toString(),
                  child: Text(item['item_name']?.toString() ?? ''),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedIngredient = value;
                });
              },
              validator: (value) =>
                  value == null ? 'Please select an ingredient' : null,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: "Quantity",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: _selectedUnit,
                    decoration: const InputDecoration(
                      labelText: "Unit",
                      border: OutlineInputBorder(),
                    ),
                    items: _measurementUnits.map((unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedUnit = value;
                      });
                    },
                    validator: (value) => value == null ? 'Select unit' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  insertIngredients();
                },
                icon: const Icon(Icons.add),
                label: Text("Add Ingredient"),
              ),
            ),
            const SizedBox(height: 20),
            ListView.builder(
              itemCount: ingredients.length,
              shrinkWrap: true,

              itemBuilder: (context, index) {
                final ingredient = ingredients[index];
                return Container(
                  margin: EdgeInsets.all(4),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 244, 209),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(ingredient['tbl_item']['item_name']?.toString() ?? ''),
                      Text("${ingredient['ingredient_quantity']?.toString()} ${ingredient['ingredient_unit']?.toString()}"),
                      IconButton(
  onPressed: () {
    deleteIngredient(ingredient['id']);
  },
  icon: const Icon(Icons.delete_forever_sharp, color: Colors.red),
),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1F7D53),
                foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Instructions(recipieId: widget.recipieId,)),
                );
              },
              child: const Text("NEXT"),
            ),
          ],
        ),
      ),
    );
  }
}
