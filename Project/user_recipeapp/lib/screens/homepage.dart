import 'package:flutter/material.dart';
import 'package:user_recipeapp/screens/analytics.dart';
import 'package:user_recipeapp/screens/change_password.dart';
import 'package:user_recipeapp/screens/createrecipe.dart';
import 'package:user_recipeapp/screens/editprofile.dart';
import 'package:user_recipeapp/screens/favorties.dart';
import 'package:user_recipeapp/screens/profile.dart';
import 'package:user_recipeapp/screens/recipie_suggestion.dart';
import 'package:user_recipeapp/screens/user_complaints.dart';
import 'package:user_recipeapp/screens/user_dash.dart';
import 'package:user_recipeapp/screens/user_search.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  final Color primaryColor = const Color(0xFF1F7D53);
  final Color secondaryColor = const Color(0xFF2C3E50);
  final Color accentColor = const Color(0xFFE67E22);
  final Color backgroundColor = const Color(0xFFF9F9F9);

  List<Map<String, dynamic>> pages = [
    {'label': "Home", 'icon': Icons.home, 'page': UserDashboard()},
    {'label': "Recipe", 'icon': Icons.restaurant_menu, 'page': RecipeSearchAndSuggestionPage()},
    {
      'label': "Add Recipe",
      'icon': Icons.add_circle_outline_sharp,
      'page': Createrecipe()
    },
    {
      'label': "Search",
      'icon': Icons.search_outlined,
      'page': SearchUsersPage()
    },
    {
      'label': "Profile",
      'icon': Icons.person_outline_outlined,
      'page': Profile()
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _selectedIndex !=1 ? AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        title: _selectedIndex == 4 ? Text("Recipe App") : const Text(
          "Find Best Recipes for Cooking",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          _selectedIndex == 4 ? PopupMenuButton(
            padding: EdgeInsets.symmetric(horizontal: 10),
            popUpAnimationStyle: AnimationStyle(
              curve: Curves.easeInQuint,
              // duration: const Duration(milliseconds: 400),
              reverseCurve: Curves.easeOutQuint,
              // reverseDuration: const Duration(milliseconds: 400),

            ),
            child: Icon(Icons.more_vert_outlined),
            itemBuilder: (context) {
            return [
              PopupMenuItem(
                child: TextButton(
                  onPressed: () async {
                    final result = await Navigator.push(context,
                        MaterialPageRoute(builder: (context) => EditProfile()));
                    if (result == true) {
                      setState(() {
                        
                      });
                    }
                  },
                  child: const Text("Profile"),
                ),
              ),
              PopupMenuItem(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ChangePasswordPage()));
                  },
                  child: const Text("Change Password"),
                ),
              ),
              PopupMenuItem(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Favorties()));
                  },
                  child: const Text("Favorites"),
                ),
              ),
              PopupMenuItem(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ComplaintsPage()));
                  },
                  child: const Text("Complaints"),
                ),
              ),
              PopupMenuItem(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AnalyticsPage()));
                  },
                  child: const Text("Analytics"),
                ),
              )
            ];
          },) : SizedBox()
        ],
      ) : null,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Container(
          key: ValueKey<int>(_selectedIndex),
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: pages[_selectedIndex]['page']),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(pages.length, (index) {
                final isSelected = _selectedIndex == index;
                final isCreateButton = index == 2; // Add Recipe button
                
                if (isCreateButton) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        pages[index]['icon'],
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  );
                }
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          pages[index]['icon'],
                          color: isSelected ? primaryColor : Colors.grey,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pages[index]['label'],
                        style: TextStyle(
                          color: isSelected ? primaryColor : Colors.grey,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
