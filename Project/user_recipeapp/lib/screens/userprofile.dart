import 'package:flutter/material.dart';
import 'package:user_recipeapp/main.dart';
import 'package:user_recipeapp/screens/addcomment.dart';
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
  String btn = "Loading....";

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

  followCheck() async {
    try {
      final response = await supabase
          .from('tbl_follow')
          .select()
          .eq('following_id', widget.uid)
          .eq('follower_id', supabase.auth.currentUser!.id);
      if (response.length > 0) {
        setState(() {
          btn = "Unfollow";
        });
      } else {
        setState(() {
          btn = "Follow";
        });
      }
    } catch (e) {
      print("Error fetching follower: $e");
      
    }
  }

  Future<void> fetchRecipe() async {
    try {
      final response = await supabase
          .from("tbl_recipe")
          .select()
          .eq('user_id', widget.uid)
          .eq('recipe_status', 1);
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
    followCheck();
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
              onPressed: btn != "Loading...." ? () {
                if(btn == "Follow"){
                  supabase.from('tbl_follow').upsert([
                    {
                      'follower_id': supabase.auth.currentUser!.id,
                      'following_id': widget.uid,
                    }
                  ]).then((value) {
                    setState(() {
                      btn = "Unfollow";
                    });
                  });
                } else {
                  supabase.from('tbl_follow').delete().eq('follower_id', supabase.auth.currentUser!.id).eq('following_id', widget.uid).then((value) {
                    setState(() {
                      btn = "Follow";
                    });
                  });
                }
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color.fromRGBO(31, 125, 83, 1), // Custom green color
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 12), // Adjusted padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Smooth square shape
                  side: const BorderSide(
                      color: Color.fromRGBO(25, 105, 70, 1),
                      width: 1.5), // Slightly darker border
                ),
                elevation: 10, // Added shadow for depth
                shadowColor: Colors.black.withOpacity(1), // Soft shadow color
              ),
              child: Text(
                btn,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white, // White text for contrast
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
                          builder: (context) =>
                              ViewRecipe(recipeId: data['id']),
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
                                    Icons.favorite,
                                    color: Color.fromARGB(255, 255, 255, 255),
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
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AddComment(recipeId: data['id']),
                                      ),
                                    );
                                  },
                                  child: const Icon(
                                    Icons.mode_comment_outlined,
                                    color: Colors.grey,
                                    size: 30,
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
