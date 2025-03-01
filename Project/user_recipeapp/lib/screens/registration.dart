import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user_recipeapp/components/form_validation.dart';
import 'package:user_recipeapp/main.dart';
import 'package:user_recipeapp/screens/login.dart';
import 'package:path/path.dart' as path; 

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {

  List<Map<String, dynamic>> registrationList = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController =
      TextEditingController();
  final formkey = GlobalKey<FormState>();
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

  Future<String?> _uploadImage(String uid) async {
    try {

      // Extract file extension from _image!
      String fileExtension =
          path.extension(_image!.path); // Example: .jpg, .png

      // Generate filename with extension
      String fileName = 'User-$uid$fileExtension';

      await supabase.storage.from('reciepes').upload(fileName, _image!);

      // Get public URL of the uploaded image
      final imageUrl = supabase.storage.from('reciepes').getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      print('Image upload failed: $e');
      return null;
    }
  }

  Future<void> register() async {
    try {
      final authentication = await supabase.auth.signUp(
          password: _passwordController.text, email: _emailController.text);
      String uid = authentication.user!.id;
      insertUser(uid);
    } catch (e) {
      print("Error registration: $e");
    }
  }

  Future<void> insertUser(String uid) async {
    try {
      String name = _nameController.text;
      String email = _emailController.text;
      String contact = _contactController.text;
      String password = _passwordController.text;
      String? url = await _uploadImage(uid); 
      await supabase.from('tbl_user').insert({
        'user_id': uid,
        'user_name': name,
        'user_email': email,
        'user_contact': contact,
        'user_password': password,
        'user_photo': url,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "REGISTRATED SUCCESSFULLY",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ));
      _nameController.clear();
      _emailController.clear();
       _contactController.clear();
        _passwordController.clear();
         _confirmpasswordController.clear();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Failed. Please Try Again!!",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));
      print("ERROR REGISTERING: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 251, 251, 251),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 251, 251, 251),
        title: Center(child: Text(" REGISTRATION")),
      ),
      body: Form(
        key: formkey,
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          children: [
           GestureDetector(
  onTap: _pickImage, // Your image picker function
  child: CircleAvatar(
    radius: 100, // Adjust size as needed
    backgroundColor: Colors.grey[200],
    // If an image is selected, show it as backgroundImage
    backgroundImage: _image != null ? FileImage(_image!) : null,
    // If no image is selected, show an icon in the center
    child: _image == null
        ? const Icon(
            Icons.person, // or Icons.add_a_photo
            color: Color.fromARGB(255, 58, 58, 58),
            size: 50,
          )
        : null,
  ),
),


            SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: _nameController,
              validator: (value) => FormValidation.validateName(value),
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(25))),
                filled: true,
                fillColor: Color.fromARGB(255, 236, 236, 236),
                labelText: "Name",
                prefixIcon: Icon(Icons.account_circle),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: _emailController,
              validator: (value) => FormValidation.validateEmail(value),
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(25))),
                filled: true,
                fillColor: Color.fromARGB(255, 236, 236, 236),
                labelText: "Email",
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: _contactController,
              validator: (value) => FormValidation.validateContact(value),
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(25))),
                filled: true,
                fillColor: Color.fromARGB(255, 236, 236, 236),
                labelText: "Contact",
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              obscureText: true,
              controller: _passwordController,
              validator: (value) => FormValidation.validatePassword(value),
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(25))),
                filled: true,
                fillColor: Color.fromARGB(255, 236, 236, 236),
                labelText: "Password",
                prefixIcon: Icon(Icons.lock),
                suffixIcon: Icon(Icons.visibility),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              obscureText: true,
              controller: _confirmpasswordController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(25))),
                filled: true,
                fillColor: Color.fromARGB(255, 236, 236, 236),
                labelText: "Confirm Password",
                prefixIcon: Icon(Icons.lock_reset),
                suffixIcon: Icon(Icons.visibility),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed: () {
                register();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Color.fromRGBO(255, 213, 85, 1), // Custom color
                foregroundColor: Colors.black, // Text color
              ),
              child: const Text("REGISTER"),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Have an account?"),
                TextButton(
                  onPressed: () {
                 
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Login(),));
                     
                    // Navigate to sign-in screen
                  },
                  child: const Text("Sign In",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(255, 213, 85, 1),
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

