import 'package:admin_recipeapp/screens/account.dart';
import 'package:admin_recipeapp/screens/category.dart';
import 'package:admin_recipeapp/screens/cuisine.dart';
import 'package:admin_recipeapp/screens/dashboard.dart';
import 'package:admin_recipeapp/screens/diet.dart';
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
    'Category',
    'Level',
    'Ingredient',
    'Cuisine',
    'Diet',
  ];

  final List<IconData> pageIcons = [
    Icons.dashboard,
    Icons.category,
    Icons.star,
    Icons.soup_kitchen,
    Icons.restaurant,
    Icons.restaurant_menu,
  ];

  final List<Widget> pageContent = [
    Dashboard(),
    CategoryPage(),
    LevelPage(),
    Ingredient(),
    Cuisine(),
    Diet(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          pageNames[selectedIndex],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32), // Deep green for AppBar
        elevation: 5,
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Colors.white.withOpacity(0.9),
            ),
            onPressed: () {
              // Handle logout
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar (NavigationRail, using NavigationRail
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: const Color(0xFF1A3C34), // Dark green for sidebar
            unselectedIconTheme:
                IconThemeData(color: Colors.white.withOpacity(0.7)),
            unselectedLabelTextStyle: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
            selectedIconTheme: const IconThemeData(
                color: Color(0xFFA5D6A7)), // Light green for selected icon
            selectedLabelTextStyle: const TextStyle(
              color: Color(0xFFA5D6A7), // Light green for selected label
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            destinations: List.generate(pageNames.length, (index) {
              return NavigationRailDestination(
                icon: Icon(pageIcons[index]),
                selectedIcon: Icon(pageIcons[index]),
                label: Text(pageNames[index]),
              );
            }),
          ),

          // Page Content
          Expanded(
            flex: 5,
            child: Container(
              color: const Color(
                  0xFFF1F8E9), // Very light green background for content area
              padding: const EdgeInsets.all(20),
              child: pageContent[selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
