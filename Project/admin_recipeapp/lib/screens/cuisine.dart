import 'package:admin_recipeapp/main.dart';
import 'package:flutter/material.dart';

class Cuisine extends StatefulWidget {
  const Cuisine({super.key});

  @override
  State<Cuisine> createState() => _CuisineState();
}

class _CuisineState extends State<Cuisine> {
  List<Map<String, dynamic>> cuisineList = [];
  final TextEditingController _nameController = TextEditingController();
  int editID = 0;
  final formKey = GlobalKey<FormState>();

  Future<void> insertCuisine() async {
    try {
      String name = _nameController.text.trim();
      await supabase.from('tbl_cuisine').insert({'cuisine_name': name});
      showSnackbar("Cuisine Added Successfully!", Colors.green);
      _nameController.clear();
      fetchCuisine();
    } catch (e) {
      showSnackbar("Failed to add cuisine. Try again!", Colors.red);
      print("ERROR ADDING CUISINE: $e");
    }
  }

  Future<void> fetchCuisine() async {
    try {
      final response = await supabase.from('tbl_cuisine').select();
      setState(() {
        cuisineList = response;
      });
    } catch (e) {
      print("ERROR FETCHING CUISINES: $e");
    }
  }

  Future<void> deleteCuisine(String id) async {
    try {
      await supabase.from("tbl_cuisine").delete().eq("id", id);
      showSnackbar("Cuisine Deleted", Colors.redAccent);
      fetchCuisine();
    } catch (e) {
      print("ERROR DELETING CUISINE: $e");
    }
  }

  Future<void> editCuisine() async {
    try {
      await supabase.from('tbl_cuisine').update(
        {'cuisine_name': _nameController.text.trim()},
      ).eq("id", editID);
      showSnackbar("Cuisine Updated Successfully!", Colors.blueAccent);
      setState(() {
        editID = 0;
      });
      _nameController.clear();
      fetchCuisine();
    } catch (e) {
      print("ERROR EDITING CUISINE: $e");
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
    fetchCuisine();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Cuisine Input Form
          Card(
            elevation: 5,
            color: Color(0xFFFBE799), // Good Beige
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                          return "Please enter a cuisine name.";
                        }
                        if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                          return 'Name must contain only letters.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Cuisine Name",
                        labelStyle: TextStyle(color: Colors.black54),
                        hintText: "Enter cuisine",
                        hintStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.fastfood, color: Colors.amber),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          if (editID == 0) {
                            insertCuisine();
                          } else {
                            editCuisine();
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 245, 245, 245), // Yellow
                        minimumSize: Size(100, 50), // Full-width & taller button
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero, // Rectangular shape
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        elevation: 4,
                      ),
                      child: Text(
                        editID == 0 ? "Add Cuisine" : "UPDATE CUISINE",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 126, 126, 126),
                          fontSize: 14, // Bigger font
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

          // Cuisine List (Shorter & Prettier Cards)
          Expanded(
            child: ListView.builder(
              itemCount: cuisineList.length,
              itemBuilder: (context, index) {
                final data = cuisineList[index];
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
                      child: Icon(Icons.restaurant_menu, color: Colors.black87),
                    ),
                    title: Text(
                      data['cuisine_name'],
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
                              _nameController.text = data['cuisine_name'];
                            });
                          },
                        ),
                        // Delete Button
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            deleteCuisine(data['id'].toString());
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
