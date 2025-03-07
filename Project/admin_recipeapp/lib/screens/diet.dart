import 'package:admin_recipeapp/main.dart';
import 'package:flutter/material.dart';

class Diet extends StatefulWidget {
  const Diet({super.key});

  @override
  State<Diet> createState() => _DietState();
}

class _DietState extends State<Diet> {
  List<Map<String, dynamic>> dietList = [];
  final TextEditingController _nameController = TextEditingController();
  int editID = 0;
  final formKey = GlobalKey<FormState>();

  Future<void> insertDiet() async {
    try {
      String name = _nameController.text.trim();
      await supabase.from('tbl_diet').insert({'diet_name': name});
      showSnackbar("Diet Added Successfully!", Colors.green);
      _nameController.clear();
      fetchCuisine();
    } catch (e) {
      showSnackbar("Failed to add Diet. Try again!", Colors.red);
      print("ERROR ADDING CUISINE: $e");
    }
  }

  Future<void> fetchCuisine() async {
    try {
      final response = await supabase.from('tbl_diet').select();
      setState(() {
        dietList = response;
      });
    } catch (e) {
      print("ERROR FETCHING Diet: $e");
    }
  }

  Future<void> deleteDiet(String id) async {
    try {
      await supabase.from("tbl_diet").delete().eq("id", id);
      showSnackbar("Diet Deleted", Colors.redAccent);
      fetchCuisine();
    } catch (e) {
      print("ERROR DELETING Diet $e");
    }
  }

  Future<void> editDiet() async {
    try {
      await supabase.from('tbl_diet').update(
        {'diet_name': _nameController.text.trim()},
      ).eq("id", editID);
      showSnackbar("Diet Updated Successfully!", Colors.blueAccent);
      setState(() {
        editID = 0;
      });
      _nameController.clear();
      fetchCuisine();
    } catch (e) {
      print("ERROR EDITING Diet: $e");
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
                          return "Please enter a Diet name.";
                        }
                        if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                          return 'Name must contain only letters.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Diet Name",
                        labelStyle: TextStyle(color: Colors.black54),
                        hintText: "Enter Diet",
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
                            insertDiet();
                          } else {
                            editDiet();
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
                        editID == 0 ? "Add Diet" : "UPDATE DIET",
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
              itemCount: dietList.length,
              itemBuilder: (context, index) {
                final data = dietList[index];
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
                      data['diet_name'],
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
                              _nameController.text = data['diet_name'];
                            });
                          },
                        ),
                        // Delete Button
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            deleteDiet(data['id'].toString());
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
