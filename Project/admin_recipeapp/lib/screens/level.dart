import 'package:admin_recipeapp/main.dart';
import 'package:flutter/material.dart';

class LevelPage extends StatefulWidget {
  const LevelPage({super.key});

  @override
  State<LevelPage> createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> {
  List<Map<String, dynamic>> levelList = [];
  final TextEditingController _nameController = TextEditingController();
  int editID = 0;
  final formKey = GlobalKey<FormState>();

  Future<void> insertLevel() async {
    try {
      String name = _nameController.text.trim();
      await supabase.from('tbl_level').insert({'level_name': name});
      showSnackbar("Level Added Successfully!", Colors.green);
      _nameController.clear();
      fetchLevels();
    } catch (e) {
      showSnackbar("Failed to add level. Try again!", Colors.red);
      print("ERROR ADDING LEVEL: $e");
    }
  }

  Future<void> fetchLevels() async {
    try {
      final response = await supabase.from('tbl_level').select();
      setState(() {
        levelList = response;
      });
    } catch (e) {
      print("ERROR FETCHING LEVELS: $e");
    }
  }

  Future<void> deleteLevel(String id) async {
    try {
      await supabase.from("tbl_level").delete().eq("id", id);
      showSnackbar("Level Deleted", Colors.redAccent);
      fetchLevels();
    } catch (e) {
      print("ERROR DELETING LEVEL: $e");
    }
  }

  Future<void> editLevel() async {
    try {
      await supabase.from('tbl_level').update(
        {'level_name': _nameController.text.trim()},
      ).eq("id", editID);
      showSnackbar("Level Updated Successfully!", Colors.blueAccent);
      setState(() {
        editID = 0;
      });
      _nameController.clear();
      fetchLevels();
    } catch (e) {
      print("ERROR EDITING LEVEL: $e");
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
    fetchLevels();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Level Input Form
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
                          return "Please enter a level name.";
                        }
                        if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                          return 'Name must contain only letters.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Level Name",
                        labelStyle: TextStyle(color: Colors.black54),
                        hintText: "Enter level",
                        hintStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.stairs, color: Colors.amber),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          if (editID == 0) {
                            insertLevel();
                          } else {
                            editLevel();
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
                        editID == 0 ? "ADD LEVEL" : "UPDATE LEVEL",
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

          // Level List (Shorter & Prettier Cards)
          Expanded(
            child: ListView.builder(
              itemCount: levelList.length,
              itemBuilder: (context, index) {
                final data = levelList[index];
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
                      child: Icon(Icons.emoji_events, color: Colors.black87),
                    ),
                    title: Text(
                      data['level_name'],
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
                              _nameController.text = data['level_name'];
                            });
                          },
                        ),
                        // Delete Button
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            deleteLevel(data['id'].toString());
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
