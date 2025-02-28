import 'package:flutter/material.dart';
import 'package:user_recipeapp/main.dart';
import 'package:user_recipeapp/screens/createingredients.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path; // Import path package

class Createrecipe extends StatefulWidget {
  const Createrecipe({super.key});

  @override
  State<Createrecipe> createState() => _CreaterecipeState();
}

final TextEditingController _titleController = TextEditingController();
final TextEditingController _descriptionController = TextEditingController();
final TextEditingController _servingsizeController = TextEditingController();
final TextEditingController _cookingtimeController = TextEditingController();
final TextEditingController _calorieController = TextEditingController();


List<Map<String, dynamic>> categoryList = [];
class _CreaterecipeState extends State<Createrecipe> {

  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage() async {
    try {
      // Get current date and time
      String formattedDate =
          DateFormat('dd-MM-yyyy-HH-mm').format(DateTime.now());

      // Extract file extension from _image!
      String fileExtension =
          path.extension(_image!.path); // Example: .jpg, .png

      // Generate filename with extension
      String fileName = 'Recipe-$formattedDate$fileExtension';

      await supabase.storage.from('reciepes').upload(fileName, _image!);

      // Get public URL of the uploaded image
      final imageUrl = supabase.storage.from('reciepes').getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      print('Image upload failed: $e');
      return null;
    }
  }

  Future<void> insertRecipe() async {
    try {
      String title = _titleController.text;
      String description = _descriptionController.text;
      String servingsize = _servingsizeController.text;
      String cookingtime = _cookingtimeController.text;
       String calorie = _calorieController.text;
      String? url = await _uploadImage();
      final response = await supabase.from('tbl_recipe').insert({
        'recipe_name': title,
        'recipe_details': description,
        'recipe_servingsize': servingsize,
        'recipe_calorie': calorie,
        'recipe_cookingtime': cookingtime,
        'recipe_photo': url
      }).select('id').single();
      String id = response['id'].toString();
      print("Passing ID: $id");
       Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Ingredients(recipieId: id,)),
                  );
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

Future<void> fetchcategory() async {
    try {
      final response = await supabase.from("tbl_category").select();
      setState(() {
        categoryList = response;
      });
    } catch (e) {
      print("Error fetching category: $e");
    }
  }
  @override
  void initState() {
    fetchcategory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Upload Placeholder
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                  image: _image != null
                      ? DecorationImage(
                          image: FileImage(_image!), fit: BoxFit.cover)
                      : null,
                ),
                child: _image == null
                    ? const Center(child: Text("Add Image"))
                    : null, // Remove text when an image is selected
              ),
            ),
            const SizedBox(height: 20),

            // Recipe Title
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Recipe Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 20),
            // Serving Size
            TextFormField(
              controller: _servingsizeController,
              decoration: InputDecoration(
                labelText: "Serving Size",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _calorieController,
              decoration: InputDecoration(
                labelText: "Calories",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _cookingtimeController,
              decoration: InputDecoration(
                labelText: "Cooking time",
                border: OutlineInputBorder(),
              ),
              
            ),
            const SizedBox(height: 30),
            // Add Step Button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(
                      255, 213, 85, 1), // Change this to any color you want
                  foregroundColor:
                      const Color.fromARGB(255, 0, 0, 0), // Text color
                  minimumSize: const Size(200, 50), // Width: 200, Height: 50
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        8), // Rectangular shape with slight rounding
                  ),
                ),
                onPressed: () {
                 insertRecipe();
                },
                child: const Text("NEXT"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
