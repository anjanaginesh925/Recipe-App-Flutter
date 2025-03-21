import 'package:flutter/material.dart';
import 'package:admin_recipeapp/main.dart'; // Assuming supabase is here
import 'package:fl_chart/fl_chart.dart'; // Add this package for charts

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool isLoading = true;
  int totalRecipes = 0;
  int totalUsers = 0;
  List<Map<String, dynamic>> topUsers = [];
  List<Map<String, dynamic>> topRecipes = [];
  List<Map<String, dynamic>> recipesByCategory = [];
  Map<String, int> userGrowthData = {};

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Fetch total recipes
      final recipesResponse = await supabase
          .from('tbl_recipe')
          .count();
      
      // Fetch total users
      final usersResponse = await supabase
          .from('tbl_user')
          .count();
          
      
      // Fetch top 3 users with most followers
      // First, get all users
      final usersData = await supabase
          .from('tbl_user')
          .select('user_id, user_name, user_photo');
      
      // Then, count followers for each user
      final List<Map<String, dynamic>> usersWithFollowers = [];
      
      for (var user in usersData) {
        final followersCount = await supabase
            .from('tbl_follow')
            .count()
            .eq('following_id', user['user_id']);
        
        usersWithFollowers.add({
          'user_id': user['user_id'],
          'user_name': user['user_name'],
          'user_photo': user['user_photo'],
          'follower_count': followersCount ?? 0,
        });
      }
      
      // Sort by follower count and take top 3
      usersWithFollowers.sort((a, b) => 
        (b['follower_count'] as int).compareTo(a['follower_count'] as int));
      
      final topUsersData = usersWithFollowers.take(3).toList();
      
      // Fetch top 3 recipes based on average rating
      // First, get all recipes with their details
      final recipesData = await supabase
          .from('tbl_recipe')
          .select('id, recipe_name, recipe_photo');
      
      // Then, calculate average rating for each recipe
      final List<Map<String, dynamic>> recipesWithRatings = [];
      
      for (var recipe in recipesData) {
        final ratingsData = await supabase
            .from('tbl_comment')
            .select('comment_ratingvalue')
            .eq('recipe_id', recipe['id'])
            .not('comment_ratingvalue', 'is', null);
        
        double totalRating = 0;
        int ratingCount = 0;
        
        for (var rating in ratingsData) {
          if (rating['comment_ratingvalue'] != null) {
            totalRating += rating['comment_ratingvalue'];
            ratingCount++;
          }
        }
        
        double avgRating = ratingCount > 0 ? totalRating / ratingCount : 0;
        
        recipesWithRatings.add({
          'id': recipe['id'],
          'recipe_name': recipe['recipe_name'],
          'recipe_photo': recipe['recipe_photo'],
          'avg_rating': avgRating,
          'rating_count': ratingCount,
        });
      }
      
      // Sort by average rating and take top 3
      recipesWithRatings.sort((a, b) => 
        (b['avg_rating'] as double).compareTo(a['avg_rating'] as double));
      
      final topRecipesData = recipesWithRatings.take(3).toList();
      
      // Fetch recipe count by category
      final categoriesData = await supabase
          .from('tbl_category')
          .select('id, category_name');
      
      final List<Map<String, dynamic>> categoryWithCounts = [];
      
      for (var category in categoriesData) {
        final recipeCount = await supabase
            .from('tbl_recipe')
            .count()
            .eq('category_id', category['id']);
        
        categoryWithCounts.add({
          'category_id': category['id'],
          'category_name': category['category_name'],
          'count': recipeCount ?? 0,
        });
      }
      
      // Sort by count
      categoryWithCounts.sort((a, b) => 
        (b['count'] as int).compareTo(a['count'] as int));
      
      // Calculate user growth data (monthly)
      final usersWithDates = await supabase
          .from('tbl_user')
          .select('created_at');
      
      final Map<String, int> monthlyGrowth = {};
      
      for (var user in usersWithDates) {
        final createdAt = DateTime.parse(user['created_at']);
        final monthKey = '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}';
        
        if (monthlyGrowth.containsKey(monthKey)) {
          monthlyGrowth[monthKey] = (monthlyGrowth[monthKey] ?? 0) + 1;
        } else {
          monthlyGrowth[monthKey] = 1;
        }
      }
      
      setState(() {
        totalRecipes = recipesResponse ?? 0;
        totalUsers = usersResponse ?? 0;
        topUsers = topUsersData;
        topRecipes = topRecipesData;
        recipesByCategory = categoryWithCounts;
        userGrowthData = monthlyGrowth;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching dashboard data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.deepPurple,
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message
          const Text(
            'Welcome to Recipe Admin Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Overview of your recipe application',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // Stats Cards
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStatCard(
                'Total Recipes',
                totalRecipes.toString(),
                Icons.menu_book,
                Colors.orange,
              ),
              _buildStatCard(
                'Total Users',
                totalUsers.toString(),
                Icons.people,
                Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Top Users Section
          const Text(
            'Top Users with Most Followers',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: topUsers.isEmpty
                ? _buildEmptyState('No user data available')
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: topUsers.length,
                    itemBuilder: (context, index) {
                      final user = topUsers[index];
                      return _buildTopUserCard(
                        user['user_name'] ?? 'Unknown',
                        user['user_photo'],
                        user['follower_count'] ?? 0,
                        index + 1,
                      );
                    },
                  ),
          ),
          const SizedBox(height: 24),

          // Top Recipes Section
          const Text(
            'Top Rated Recipes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          topRecipes.isEmpty
              ? _buildEmptyState('No recipe data available')
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: topRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = topRecipes[index];
                    return _buildTopRecipeCard(
                      recipe['recipe_name'] ?? 'Unknown Recipe',
                      recipe['recipe_photo'],
                      recipe['avg_rating'] ?? 0.0,
                      recipe['rating_count'] ?? 0,
                      index + 1,
                    );
                  },
                ),
          const SizedBox(height: 24),

          // Charts Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipes by Category Chart
              Expanded(
                child: Container(
                  height: 300,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recipes by Category',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: recipesByCategory.isEmpty
                            ? _buildEmptyState('No category data')
                            : PieChart(
                                PieChartData(
                                  sections: _createPieChartSections(),
                                  centerSpaceRadius: 40,
                                  sectionsSpace: 2,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // User Growth Chart
              Expanded(
                child: Container(
                  height: 300,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'User Growth (Monthly)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: userGrowthData.isEmpty
                            ? _buildEmptyState('No growth data')
                            : LineChart(
                                LineChartData(
                                  gridData: FlGridData(show: false),
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          final sortedKeys = userGrowthData.keys.toList()..sort();
                                          if (value.toInt() >= 0 && 
                                              value.toInt() < sortedKeys.length) {
                                            final monthYear = sortedKeys[value.toInt()].split('-');
                                            final month = int.parse(monthYear[1]);
                                            final monthNames = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                                            return Text(
                                              monthNames[month],
                                              style: const TextStyle(fontSize: 10),
                                            );
                                          }
                                          return const Text('');
                                        },
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: _createLineChartSpots(),
                                      isCurved: true,
                                      color: Colors.deepPurple,
                                      barWidth: 3,
                                      isStrokeCapRound: true,
                                      dotData: FlDotData(show: true),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: Colors.deepPurple.withOpacity(0.2),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to build stat cards
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build top user cards
  Widget _buildTopUserCard(String name, String? photoUrl, int followers, int rank) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _getRankColor(rank),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // User photo
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey[200],
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
            child: photoUrl == null ? const Icon(Icons.person, color: Colors.grey) : null,
          ),
          const SizedBox(width: 12),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$followers followers',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build top recipe cards
  Widget _buildTopRecipeCard(String name, String? photoUrl, double rating, int ratingCount, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _getRankColor(rank),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Recipe image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: photoUrl != null
                ? Image.network(
                    photoUrl,
                    width: 80,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 80,
                      height: 60,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  )
                : Container(
                    width: 80,
                    height: 60,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
          ),
          const SizedBox(width: 16),
          // Recipe info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // Star rating
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < rating.floor() 
                              ? Icons.star 
                              : (index < rating) 
                                  ? Icons.star_half 
                                  : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${rating.toStringAsFixed(1)} ($ratingCount ${ratingCount == 1 ? 'review' : 'reviews'})',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for empty state
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            size: 40,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get rank color
  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber; // Gold
      case 2:
        return Colors.blueGrey; // Silver
      case 3:
        return Colors.brown; // Bronze
      default:
        return Colors.grey;
    }
  }

  // Helper method to create pie chart sections
  List<PieChartSectionData> _createPieChartSections() {
    final List<Color> colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    return recipesByCategory.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final color = colors[index % colors.length];
      
      // Skip categories with zero recipes
      if (data['count'] == 0) {
        return PieChartSectionData(
          color: Colors.transparent,
          value: 0,
          title: '',
          radius: 0,
        );
      }
      
      return PieChartSectionData(
        color: color,
        value: (data['count'] ?? 0).toDouble(),
        title: '${data['category_name']}\n${data['count']}',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  // Helper method to create line chart spots
  List<FlSpot> _createLineChartSpots() {
    final sortedKeys = userGrowthData.keys.toList()..sort();
    return sortedKeys.asMap().entries.map((entry) {
      final index = entry.key;
      final monthKey = entry.value;
      return FlSpot(index.toDouble(), userGrowthData[monthKey]?.toDouble() ?? 0);
    }).toList();
  }
}