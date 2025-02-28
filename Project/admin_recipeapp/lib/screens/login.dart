import 'package:admin_recipeapp/main.dart';
import 'package:admin_recipeapp/screens/homepage.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  void signin() {}
  Future<void> signIn() async {
    try {
      String email = _emailController.text;
      String password = _passController.text;
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
       final User? user = res.user;
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Homepage() ),
        );
      }
      print('SignIn Successful');
     
    } catch (e) {
      print('Error During SignIn: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Expanded(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/login-bg.jpg'), fit: BoxFit.cover)
          ),
          child: Center(
            child: Container(
              width: 400,
              height: 500,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 48, 48, 48).withOpacity(0.7),
                    spreadRadius: 3,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: ListView(
                padding: EdgeInsets.all(50),
                children: [
                  TextFormField(
                    controller: _emailController,
                    style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.grey,
                          )),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: const Color.fromARGB(255, 202, 202, 202),
                      ),
                      hintText: "Enter Email Address",
                      labelText: "Email Address",
                      labelStyle:
                          TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.grey,
                          )),
                      hintStyle: TextStyle(
                        color: const Color.fromARGB(255, 198, 198, 198),
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  
                  TextFormField(
                    controller: _passController,
                    keyboardType: TextInputType.visiblePassword,
                    style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.grey,
                          )),
                      prefixIcon: Icon(
                        Icons.lock,
                        color: const Color.fromARGB(255, 204, 204, 204),
                      ),
                      suffixIcon: Icon(
                        Icons.visibility,
                        color: const Color.fromARGB(255, 204, 204, 204),
                      ),
                      hintText: "Please Enter Password",
                      labelText: "Password",
                      labelStyle:
                          TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.grey,
                          )),
                      hintStyle: TextStyle(
                        color: const Color.fromARGB(255, 196, 196, 196),
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      signIn();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 147, 64),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text(
                        "LOGIN",
                        style: const TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
