import 'package:flutter/material.dart';
import 'package:user_recipeapp/main.dart';
import 'package:user_recipeapp/screens/editprofile.dart';
import 'package:user_recipeapp/screens/viewrecipe.dart';

class UserProfile extends StatefulWidget {
  final String uid;
  const UserProfile({super.key, required this.uid});


  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  List<Map<String, dynamic>> recipeList = [];
  String name = '';
  String image = '';

  Future<void> fetchUser() async {
    try {
      final response = await supabase
          .from('tbl_user')
          .select()
          .eq('user_id', widget.uid)
          .single();
      setState(() {
        name = response['user_name']?.toString() ?? 'Unknown User';
        image = response['user_photo']?.toString() ?? '';
      });
    } catch (e) {
      print("Error fetching user: $e");
    }
  }

  Future<void> fetchRecipe() async {
    try {
      final response = await supabase
          .from("tbl_recipe")
          .select()
          .eq('user_id', widget.uid).eq('recipe_status', 1);
      setState(() {
        recipeList = response;
      });
    } catch (e) {
      print("Error fetching recipe: $e");
    }
  }

  void addToFavorites(String recipeId) {
    // Implement logic to add to favorites
    print("Added to favorites: $recipeId");
  }

  void openComments(String recipeId) {
    // Implement logic to open comment section
    print("Open comments for: $recipeId");
  }

  @override
  void initState() {
    super.initState();
    fetchRecipe();
    fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Profile")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Profile Picture
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(image),
              child: image == ""
                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
            ),

            const SizedBox(height: 10),

            // User Name
            Text(
              name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 50),

           ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFFFF8DC), // Light pastel yellow
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8), // Smooth square shape
      side: const BorderSide(color: Color(0xFFFFE4B5), width: 1.5), // Softer yellow border
    ),
    elevation: 0, // Flat, modern look
  ),
  child: const Text(
    'Follow',
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.black, // Black text for contrast
      letterSpacing: 0.8,
    ),
  ),
),


            const SizedBox(height: 50),

            // Grid for Posts
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.all(5),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 0.75,
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: recipeList.length,
              itemBuilder: (context, index) {
                final data = recipeList[index];

                return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewRecipe(recipeId: data['id']),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              // Recipe Image
                              SizedBox(
                                height: 195,
                                width: double.infinity,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    data['recipe_photo']?.toString() ?? '',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                              // Heart (Favorite) Icon (Top-Right)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => addToFavorites(data['id']),
                                  child: const Icon(
                                    Icons.favorite_border,
                                    color: Color.fromARGB(255, 2, 2, 2),
                                    size: 24,
                                  ),
                                ),
                              ),

                              // Cooking Time (Bottom-Left)
                              Positioned(
                                bottom: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time,
                                          color: Colors.white, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        data['recipe_cookingtime']
                                                ?.toString() ??
                                            'N/A',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Rating & Comments Section
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.star,
                                        color: Colors.amber, size: 18),
                                    SizedBox(width: 4),
                                    Text("4.5",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),

                                // Comment Icon (Functional)
                                GestureDetector(
                                  onTap: () => openComments(data['id']),
                                  child: const Icon(
                                    Icons.mode_comment_outlined,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Recipe Name
                          SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                data['recipe_name']?.toString() ??
                                    'Unknown Recipe',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
