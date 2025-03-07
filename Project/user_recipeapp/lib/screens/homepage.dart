import 'package:flutter/material.dart';
import 'package:user_recipeapp/screens/createrecipe.dart';
import 'package:user_recipeapp/screens/favorties.dart';
import 'package:user_recipeapp/screens/profile.dart';
import 'package:user_recipeapp/screens/recipie_suggestion.dart';
import 'package:user_recipeapp/screens/search.dart';
import 'package:user_recipeapp/screens/user_dash.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  List<Map<String, dynamic>> pages = [
    {'label': "Home", 'icon': Icons.home, 'page': UserDashboard()},
    {'label': "Search", 'icon': Icons.search, 'page': SelectItemsPage()},
    {
      'label': "Add Recipe",
      'icon': Icons.add_circle_outline_sharp,
      'page': Createrecipe()
    },
    {'label': "Favorites", 'icon': Icons.favorite_border, 'page': Favorties()},
    {
      'label': "Profile",
      'icon': Icons.person_outline_outlined,
      'page': Profile()
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Find Best Recipes for Cooking",
          style: TextStyle(fontWeight: FontWeight.bold,),
        ),
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: pages[_selectedIndex]['page']),
      bottomNavigationBar: BottomNavigationBar(
          unselectedItemColor: const Color.fromARGB(255, 141, 141, 141),
          selectedItemColor: Color.fromRGBO(255, 213, 85, 1),
          currentIndex: _selectedIndex,
          onTap: (value) {
            if(value == 1){
              Navigator.push(context, MaterialPageRoute(builder: (context) => SelectItemsPage()));
            }
            setState(() {
              _selectedIndex = value;
            });
          },
          items: pages.map(
            (item) {
              return BottomNavigationBarItem(
                icon: Icon(item['icon']),
                label: item['label'],
              );
            },
          ).toList()),
    );
  }
}
