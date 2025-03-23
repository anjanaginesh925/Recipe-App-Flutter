import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:user_recipeapp/main.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  int totalViews = 0;
  double followerViewsPercentage = 0.0;
  double nonFollowerViewsPercentage = 0.0;

  final Color primaryColor = const Color(0xFF1F7D53);
  final Color secondaryColor = const Color(0xFF2C3E50);
  final Color accentColor = const Color(0xFFE67E22);

  Future<void> _fetchAnalytics() async {
    try {
      // Fetch all recipes by the current user
      final recipesResponse = await supabase
          .from('tbl_recipe')
          .select('id')
          .eq('user_id', supabase.auth.currentUser!.id);

      List<Map<String, dynamic>> recipes =
          List<Map<String, dynamic>>.from(recipesResponse);
      List<String> recipeIds = recipes.map((r) => r['id'].toString()).toList();

      // Fetch views (tbl_recent) for these recipes
      final viewsResponse = await supabase
          .from('tbl_recent')
          .select('user_id')
          .inFilter('recipe_id', recipeIds);

      List<Map<String, dynamic>> views =
          List<Map<String, dynamic>>.from(viewsResponse);

      // Calculate total views
      totalViews = views.length;

      // Fetch followers of the current user
      final followersResponse = await supabase
          .from('tbl_follow')
          .select('follower_id')
          .eq('following_id', supabase.auth.currentUser!.id);

      List<String> followerIds = List<Map<String, dynamic>>.from(followersResponse)
          .map((f) => f['follower_id'].toString())
          .toList();

      // Calculate follower vs non-follower views
      int followerViews = 0;
      for (var view in views) {
        if (followerIds.contains(view['user_id'].toString())) {
          followerViews++;
        }
      }
      int nonFollowerViews = totalViews - followerViews;

      followerViewsPercentage = totalViews > 0 ? (followerViews / totalViews) * 100 : 0.0;
      nonFollowerViewsPercentage = totalViews > 0 ? (nonFollowerViews / totalViews) * 100 : 0.0;
    } catch (e) {
      print('Error fetching analytics: $e');
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _fetchAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recipe Views Analytics',
          style: TextStyle(color: secondaryColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryColor.withOpacity(0.05), Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: totalViews == 0
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.pie_chart_outline,
                          size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 20),
                      Text(
                        'No views yet',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Total Views: $totalViews',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      height: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                  color: primaryColor,
                                  value: followerViewsPercentage,
                                  title: '',
                                  radius: 50,
                                ),
                                PieChartSectionData(
                                  color: accentColor,
                                  value: nonFollowerViewsPercentage,
                                  title: '',
                                  radius: 50,
                                ),
                              ],
                              sectionsSpace: 0,
                              centerSpaceRadius: 60,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${followerViewsPercentage.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: secondaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Followers',
                                style: TextStyle(
                                  color: secondaryColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            left: 0,
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  color: primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Followers',
                                  style: TextStyle(
                                    color: secondaryColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            right: 0,
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  color: accentColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Non-followers ${nonFollowerViewsPercentage.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    color: secondaryColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}