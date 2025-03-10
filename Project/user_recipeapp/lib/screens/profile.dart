import 'package:flutter/material.dart';
import 'package:user_recipeapp/main.dart';
import 'package:user_recipeapp/screens/editprofile.dart';
import 'package:user_recipeapp/screens/viewrecipe.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  List<Map<String, dynamic>> userList = [];
  List<Map<String, dynamic>> recipeList = [];
  String name = '';
  String image = '';

  Future<void> fetchUser() async {
    try {
      final response = await supabase
          .from('tbl_user')
          .select()
          .eq('user_id', supabase.auth.currentUser!.id)
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
          .eq('user_id', supabase.auth.currentUser!.id);
      setState(() {
        recipeList = response;
      });
    } catch (e) {
      print("Error fetching recipe: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRecipe();
    fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),

        // Profile Picture
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey,
          backgroundImage: NetworkImage(image),
          child: image == ""
              ? Icon(Icons.person, size: 50, color: Colors.white)
              : null,
        ),

        const SizedBox(height: 10),

        // User Name
        Text(
          name,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 5),

        // Edit Profile Button
        TextButton(
          onPressed: () {
            Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfile()
                    ),
                  );
          },
          child: const Text('Edit Profile'),
        ),

        const SizedBox(height: 10),

        // Stats Row (Posts, Followers, Following)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text(recipeList.length.toString(),
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Posts'),
              ],
            ),
            Column(
              children: const [
                Text('100',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Followers'),
              ],
            ),
            Column(
              children: const [
                Text('50',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Following'),
              ],
            ),
          ],
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
                    color: const Color.fromARGB(255, 255, 255, 255),
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

                          // Three-dot menu (Top-Right)
                          const Positioned(
                            top: 8,
                            right: 8,
                            child: Icon(Icons.more_vert,
                                color: Color.fromARGB(255, 0, 0, 0)),
                          ),

                          // Cooking Time (Bottom-Left)
                          Positioned(
                            bottom: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black
                                    .withOpacity(0.6), // Semi-transparent black
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      color: Colors.white, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    data['recipe_cookingtime']?.toString() ??
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

                      // Small section at the bottom for rating
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                              255, 255, 255, 255), // Light background color
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.star, color: Colors.amber, size: 18),
                                SizedBox(width: 4),
                                Text("4.5",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            data['recipe_name']?.toString() ?? 'Unknown Recipe',
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
    );
  }
}
