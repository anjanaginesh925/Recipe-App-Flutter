import 'package:flutter/material.dart';
import 'package:user_recipeapp/main.dart';
import 'package:user_recipeapp/screens/recipepage.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  List<Map<String, dynamic>> recipes = [];
  List<Map<String, dynamic>> filteredRecipes = [];
  final TextEditingController _searchController = TextEditingController();
  String? _selectedFilterType;
  String? _selectedCategory;
  String? _selectedCuisine;
  String? _selectedLevel;
  List<Map<String, dynamic>> categoryList = [];
  List<Map<String, dynamic>> cuisineList = [];
  List<Map<String, dynamic>> levelList = [];
  bool _isLoading = true;
  
  // Define app colors
  final Color primaryColor = const Color(0xFF1F7D53);
  final Color secondaryColor = const Color(0xFF2C3E50);
  final Color accentColor = const Color(0xFFE67E22);

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
    _fetchCategories();
    _fetchCuisines();
    _fetchLevels();
    _searchController.addListener(_filterRecipes);
  }

  Future<void> _fetchRecipes() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await supabase.from('tbl_recipe').select('''
        id,
        recipe_name,
        recipe_photo,
        recipe_calorie,
        recipe_cookingtime,
        recipie_type,
        category_id,
        cuisine_id,
        level_id,
        tbl_category (category_name),
        tbl_cuisine (cuisine_name),
        tbl_level (level_name)
      ''');
      setState(() {
        recipes = List<Map<String, dynamic>>.from(response);
        filteredRecipes = recipes;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching recipes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await supabase.from('tbl_category').select();
      setState(() {
        categoryList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<void> _fetchCuisines() async {
    try {
      final response = await supabase.from('tbl_cuisine').select();
      setState(() {
        cuisineList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error fetching cuisines: $e');
    }
  }

  Future<void> _fetchLevels() async {
    try {
      final response = await supabase.from('tbl_level').select();
      setState(() {
        levelList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error fetching levels: $e');
    }
  }

  void _filterRecipes() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredRecipes = recipes.where((recipe) {
        final name = recipe['recipe_name']?.toString().toLowerCase() ?? '';
        final matchesSearch = name.contains(query);

        final matchesType = _selectedFilterType == null ||
            (recipe['recipie_type']?.toString() == _selectedFilterType);

        final matchesCategory = _selectedCategory == null ||
            recipe['category_id'].toString() == _selectedCategory;

        final matchesCuisine = _selectedCuisine == null ||
            recipe['cuisine_id'].toString() == _selectedCuisine;

        final matchesLevel = _selectedLevel == null ||
            recipe['level_id'].toString() == _selectedLevel;

        return matchesSearch &&
            matchesType &&
            matchesCategory &&
            matchesCuisine &&
            matchesLevel;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedFilterType = null;
      _selectedCategory = null;
      _selectedCuisine = null;
      _selectedLevel = null;
      _searchController.clear();
      _filterRecipes();
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Filter Recipes',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipe Type Filter
              Text(
                'Recipe Type',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
                ),
              ),
              RadioListTile<String?>(
                title: const Text('Veg'),
                value: 'Veg',
                activeColor: primaryColor,
                groupValue: _selectedFilterType,
                onChanged: (value) =>
                    _updateFilter(() => _selectedFilterType = value),
              ),
              RadioListTile<String?>(
                title: const Text('Non-Veg'),
                value: 'Non-Veg',
                activeColor: primaryColor,
                groupValue: _selectedFilterType,
                onChanged: (value) =>
                    _updateFilter(() => _selectedFilterType = value),
              ),
              RadioListTile<String?>(
                title: const Text('All'),
                value: null,
                activeColor: primaryColor,
                groupValue: _selectedFilterType,
                onChanged: (value) =>
                    _updateFilter(() => _selectedFilterType = value),
              ),

              // Category Filter
              const SizedBox(height: 16),
              Text(
                'Category',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
                ),
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                hint: const Text('Select Category'),
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  const DropdownMenuItem<String>(
                      value: null, child: Text('All')),
                  ...categoryList.map((category) {
                    return DropdownMenuItem<String>(
                      value: category['id'].toString(),
                      child: Text(category['category_name'] ?? ''),
                    );
                  }),
                ],
                onChanged: (value) =>
                    _updateFilter(() => _selectedCategory = value),
              ),

              // Cuisine Filter
              const SizedBox(height: 16),
              Text(
                'Cuisine',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
                ),
              ),
              DropdownButtonFormField<String>(
                value: _selectedCuisine,
                hint: const Text('Select Cuisine'),
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  const DropdownMenuItem<String>(
                      value: null, child: Text('All')),
                  ...cuisineList.map((cuisine) {
                    return DropdownMenuItem<String>(
                      value: cuisine['id'].toString(),
                      child: Text(cuisine['cuisine_name'] ?? ''),
                    );
                  }),
                ],
                onChanged: (value) =>
                    _updateFilter(() => _selectedCuisine = value),
              ),

              // Level Filter
              const SizedBox(height: 16),
              Text(
                'Level',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
                ),
              ),
              DropdownButtonFormField<String>(
                value: _selectedLevel,
                hint: const Text('Select Level'),
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  const DropdownMenuItem<String>(
                      value: null, child: Text('All')),
                  ...levelList.map((level) {
                    return DropdownMenuItem<String>(
                      value: level['id'].toString(),
                      child: Text(level['level_name'] ?? ''),
                    );
                  }),
                ],
                onChanged: (value) =>
                    _updateFilter(() => _selectedLevel = value),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _resetFilters,
            child: Text(
              'Reset',
              style: TextStyle(color: accentColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _filterRecipes();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _updateFilter(void Function() update) {
    setState(() {
      update();
    });
  }

  // Build active filter chips
  Widget _buildActiveFilters() {
    List<Widget> chips = [];
    
    if (_selectedFilterType != null) {
      chips.add(
        Chip(
          label: Text(_selectedFilterType!),
          backgroundColor: primaryColor.withOpacity(0.1),
          labelStyle: TextStyle(color: primaryColor),
          deleteIconColor: primaryColor,
          onDeleted: () {
            setState(() {
              _selectedFilterType = null;
              _filterRecipes();
            });
          },
        ),
      );
    }
    
    if (_selectedCategory != null) {
      final category = categoryList.firstWhere(
        (c) => c['id'].toString() == _selectedCategory,
        orElse: () => {'category_name': 'Unknown'},
      );
      chips.add(
        Chip(
          label: Text(category['category_name']),
          backgroundColor: primaryColor.withOpacity(0.1),
          labelStyle: TextStyle(color: primaryColor),
          deleteIconColor: primaryColor,
          onDeleted: () {
            setState(() {
              _selectedCategory = null;
              _filterRecipes();
            });
          },
        ),
      );
    }
    
    if (_selectedCuisine != null) {
      final cuisine = cuisineList.firstWhere(
        (c) => c['id'].toString() == _selectedCuisine,
        orElse: () => {'cuisine_name': 'Unknown'},
      );
      chips.add(
        Chip(
          label: Text(cuisine['cuisine_name']),
          backgroundColor: primaryColor.withOpacity(0.1),
          labelStyle: TextStyle(color: primaryColor),
          deleteIconColor: primaryColor,
          onDeleted: () {
            setState(() {
              _selectedCuisine = null;
              _filterRecipes();
            });
          },
        ),
      );
    }
    
    if (_selectedLevel != null) {
      final level = levelList.firstWhere(
        (l) => l['id'].toString() == _selectedLevel,
        orElse: () => {'level_name': 'Unknown'},
      );
      chips.add(
        Chip(
          label: Text(level['level_name']),
          backgroundColor: primaryColor.withOpacity(0.1),
          labelStyle: TextStyle(color: primaryColor),
          deleteIconColor: primaryColor,
          onDeleted: () {
            setState(() {
              _selectedLevel = null;
              _filterRecipes();
            });
          },
        ),
      );
    }
    
    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: chips,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                "Find Your Recipe",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Discover delicious recipes for every occasion",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search recipes...",
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search, color: primaryColor),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              _filterRecipes();
                            },
                          ),
                        IconButton(
                          icon: Icon(Icons.filter_list_rounded, color: primaryColor),
                          onPressed: _showFilterDialog,
                        ),
                      ],
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor),
                    ),
                  ),
                ),
              ),
              
              // Active Filters
              _buildActiveFilters(),
              
              // Results Count
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${filteredRecipes.length} Recipes Found",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: secondaryColor,
                      ),
                    ),
                    if (filteredRecipes.isNotEmpty && filteredRecipes.length != recipes.length)
                      TextButton(
                        onPressed: _resetFilters,
                        child: Text(
                          "Clear Filters",
                          style: TextStyle(color: accentColor),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Search Results
              _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    )
                  : filteredRecipes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No recipes found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try adjusting your search or filters',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: filteredRecipes.length,
                          itemBuilder: (context, index) {
                            final recipe = filteredRecipes[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RecipePage(
                                      recipeId: recipe['id'].toString(),
                                      isEditable: false,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.15),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Recipe Image
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16),
                                      ),
                                      child: Stack(
                                        children: [
                                          recipe['recipe_photo'] != null
                                              ? Image.network(
                                                  recipe['recipe_photo'],
                                                  height: 130,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) =>
                                                      Container(
                                                    height: 130,
                                                    color: Colors.grey[200],
                                                    child: const Icon(
                                                      Icons.image_not_supported,
                                                      size: 40,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                )
                                              : Container(
                                                  height: 130,
                                                  color: Colors.grey[200],
                                                  child: const Icon(
                                                    Icons.image,
                                                    size: 40,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                          // Recipe Type Badge
                                          Positioned(
                                            top: 8,
                                            left: 8,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: recipe['recipie_type'] == 'Veg'
                                                    ? Colors.green
                                                    : Colors.red,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                recipe['recipie_type'] ?? 'N/A',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Recipe Details
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            recipe['recipe_name'] ?? 'Unnamed Recipe',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.local_fire_department,
                                                size: 14,
                                                color: accentColor,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${recipe['recipe_calorie'] ?? 'N/A'} cal',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.timer_outlined,
                                                size: 14,
                                                color: accentColor,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                recipe['recipe_cookingtime'] ?? 'N/A',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.restaurant_menu,
                                                size: 14,
                                                color: accentColor,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  recipe['tbl_cuisine']?['cuisine_name'] ?? 'N/A',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}