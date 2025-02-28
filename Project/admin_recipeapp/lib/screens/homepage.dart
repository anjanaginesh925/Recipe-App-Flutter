import 'package:admin_recipeapp/screens/account.dart';
import 'package:admin_recipeapp/screens/category.dart';
import 'package:admin_recipeapp/screens/cuisine.dart';
import 'package:admin_recipeapp/screens/dashboard.dart';
import 'package:admin_recipeapp/screens/ingredient.dart';
import 'package:admin_recipeapp/screens/level.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int selectedIndex = 0;

  final List<String> pageNames = [
    'Dashboard',
    'Account',
    'Category',
    'Level',
    'Ingredient',
    'Cuisine',
  ];

  final List<IconData> pageIcons = [
    Icons.dashboard,
    Icons.supervised_user_circle,
    Icons.category,
    Icons.star,
    Icons.soup_kitchen,
    Icons.restaurant,
  ];

  final List<Widget> pageContent = [
    Dashboard(),
    Account(),
    CategoryPage(),
    LevelPage(),
    Ingredient(),
    Cuisine(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageNames[selectedIndex], style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Handle logout
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.grey[900],
            unselectedIconTheme: IconThemeData(color: Colors.white70),
            selectedIconTheme: IconThemeData(color: Colors.deepPurpleAccent),
            destinations: List.generate(pageNames.length, (index) {
              return NavigationRailDestination(
                icon: Icon(pageIcons[index]),
                selectedIcon: Icon(pageIcons[index], color: Colors.deepPurpleAccent),
                label: Text(pageNames[index], style: TextStyle(color: Colors.white)),
              );
            }),
          ),

          // Page Content
          Expanded(
            flex: 5,
            child: Container(
              color: Colors.grey[200],
              padding: EdgeInsets.all(20),
              child: pageContent[selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
