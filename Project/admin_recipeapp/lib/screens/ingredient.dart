import 'package:admin_recipeapp/main.dart';
import 'package:flutter/material.dart';

class Ingredient extends StatefulWidget {
  const Ingredient({super.key});

  @override
  State<Ingredient> createState() => _IngredientState();
}

class _IngredientState extends State<Ingredient> {
  List<Map<String, dynamic>> ingredientList = [];
  final TextEditingController _ingredientController = TextEditingController();
  int editID = 0;
  final formKey = GlobalKey<FormState>();

  Future<void> insertIngredient() async {
    try {
      String name = _ingredientController.text.trim();
      await supabase.from('tbl_item').insert({'item_name': name});
      showSnackbar("Ingredient Added Successfully!", Colors.green);
      _ingredientController.clear();
      fetchIngredients();
    } catch (e) {
      showSnackbar("Failed to add ingredient. Try again!", Colors.red);
      print("ERROR ADDING INGREDIENT: $e");
    }
  }

  Future<void> fetchIngredients() async {
    try {
      final response = await supabase.from('tbl_item').select();
      setState(() {
        ingredientList = response;
      });
    } catch (e) {
      print("ERROR FETCHING INGREDIENTS: $e");
    }
  }

  Future<void> deleteIngredient(String id) async {
    try {
      await supabase.from("tbl_item").delete().eq("id", id);
      showSnackbar("Ingredient Deleted", Colors.redAccent);
      fetchIngredients();
    } catch (e) {
      print("ERROR DELETING INGREDIENT: $e");
    }
  }

  Future<void> editIngredient() async {
    try {
      await supabase.from('tbl_item').update(
        {'item_name': _ingredientController.text.trim()},
      ).eq("id", editID);
      showSnackbar("Ingredient Updated Successfully!", Colors.blueAccent);
      setState(() {
        editID = 0;
      });
      _ingredientController.clear();
      fetchIngredients();
    } catch (e) {
      print("ERROR EDITING INGREDIENT: $e");
    }
  }

  void showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: color,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchIngredients();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Ingredient Input Form
          Card(
            elevation: 5,
            color: Color(0xFFFBE799), // Beige background
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _ingredientController,
                      keyboardType: TextInputType.name,
                      style: TextStyle(color: Colors.black),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter an ingredient name.";
                        }
                        if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                          return 'Name must contain only letters.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Ingredient Name",
                        labelStyle: TextStyle(color: Colors.black54),
                        hintText: "Enter ingredient",
                        hintStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.kitchen, color: Colors.amber),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          if (editID == 0) {
                            insertIngredient();
                          } else {
                            editIngredient();
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 245, 245, 245),
                        minimumSize: Size(100, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero, // Rectangular shape
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        elevation: 4,
                      ),
                      child: Text(
                        editID == 0 ? "ADD INGREDIENT" : "UPDATE INGREDIENT",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 126, 126, 126),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 20),

          // Ingredient List (Shorter & Prettier Cards)
          Expanded(
            child: ListView.builder(
              itemCount: ingredientList.length,
              itemBuilder: (context, index) {
                final data = ingredientList[index];
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        offset: Offset(2, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                    leading: CircleAvatar(
                      backgroundColor: Color(0xFFFFD634), // Yellow
                      child: Icon(Icons.emoji_food_beverage, color: Colors.black87),
                    ),
                    title: Text(
                      data['item_name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        // Edit Button
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blueAccent),
                          onPressed: () {
                            setState(() {
                              editID = data['id'];
                              _ingredientController.text = data['item_name'];
                            });
                          },
                        ),
                        // Delete Button
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            deleteIngredient(data['id'].toString());
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
