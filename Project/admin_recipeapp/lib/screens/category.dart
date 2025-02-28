import 'package:admin_recipeapp/main.dart';
import 'package:flutter/material.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<Map<String, dynamic>> categoryList = [];
  final TextEditingController _nameController = TextEditingController();
  int editID = 0;
  final formKey = GlobalKey<FormState>();

  Future<void> insertCategory() async {
    try {
      String name = _nameController.text.trim();
      await supabase.from('tbl_category').insert({'category_name': name});
      showSnackbar("Category Added Successfully!", Colors.green);
      _nameController.clear();
      fetchCategories();
    } catch (e) {
      showSnackbar("Failed to add category. Try again!", Colors.red);
      print("ERROR ADDING CATEGORY: $e");
    }
  }

  Future<void> fetchCategories() async {
    try {
      final response = await supabase.from('tbl_category').select();
      setState(() {
        categoryList = response;
      });
    } catch (e) {
      print("ERROR FETCHING CATEGORIES: $e");
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await supabase.from("tbl_category").delete().eq("id", id);
      showSnackbar("Category Deleted", Colors.redAccent);
      fetchCategories();
    } catch (e) {
      print("ERROR DELETING CATEGORY: $e");
    }
  }

  Future<void> editCategory() async {
    try {
      await supabase.from('tbl_category').update(
        {'category_name': _nameController.text.trim()},
      ).eq("id", editID);
      showSnackbar("Category Updated Successfully!", Colors.blueAccent);
      setState(() {
        editID = 0;
      });
      _nameController.clear();
      fetchCategories();
    } catch (e) {
      print("ERROR EDITING CATEGORY: $e");
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
    fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Category Input Form
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
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      style: TextStyle(color: Colors.black),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter a category name.";
                        }
                        if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                          return 'Name must contain only letters.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Category Name",
                        labelStyle: TextStyle(color: Colors.black54),
                        hintText: "Enter category",
                        hintStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.category, color: Colors.amber),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          if (editID == 0) {
                            insertCategory();
                          } else {
                            editCategory();
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
                        editID == 0 ? "ADD CATEGORY" : "UPDATE CATEGORY",
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

          // Category List (Shorter & Prettier Cards)
          Expanded(
            child: ListView.builder(
              itemCount: categoryList.length,
              itemBuilder: (context, index) {
                final data = categoryList[index];
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
                      child: Icon(Icons.food_bank, color: Colors.black87),
                    ),
                    title: Text(
                      data['category_name'],
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
                              _nameController.text = data['category_name'];
                            });
                          },
                        ),
                        // Delete Button
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            deleteCategory(data['id'].toString());
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
