import 'package:flutter/material.dart';
import 'package:user_recipeapp/main.dart';
import 'package:user_recipeapp/screens/viewrecipe.dart';

class Favorties extends StatefulWidget {
  const Favorties({super.key});

  @override
  State<Favorties> createState() => _FavortiesState();
}

class _FavortiesState extends State<Favorties> {
  List<Map<String, dynamic>> favorites = [];

  Future<void> fetchFavorite() async {
    try {
      String uid = supabase.auth.currentUser!.id;
      final response = await supabase
          .from('tbl_favorite')
          .select("*, tbl_recipe(*)")
          .eq('user_id', uid);
      setState(() {
        favorites = response;
      });
    } catch (e) {
      print("Error fetching favorite recipes: $e");
    }
  }
 Future<void> deleteFavorites(int id) async {
    try {
      await supabase
          .from('tbl_favorite')
          .delete()
          .eq('id', id);
      fetchFavorite(); // Refresh list after deletion
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to delete instruction. Try again!"),
          backgroundColor: Colors.red,
        ),
      );
      print("ERROR DELETING INSTRUCTION: $e");
    }
  }

  @override
  void initState() {
    fetchFavorite();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
    
      shrinkWrap: true,
      itemCount: favorites.length, // Placeholder for now
      itemBuilder: (context, index) {
        final recipe = favorites[index]['tbl_recipe'] ?? {};
        int id = favorites[index]['id'];
        return Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(15)), // Optional rounded corners
          child: SizedBox(
            width: double.infinity, // Makes it expand fully in width
            height: 80, // Set desired height
            child: ListTile(
              leading: ClipOval(
                child: Image.network(
                  recipe['recipe_photo'],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image, size: 50),
                ),
              ),
              title: Text(recipe['recipe_name'] ?? "No Name"),
              subtitle:
                  Text(recipe['recipe_details'] ?? "No Details Available"),
              trailing: IconButton(
                icon: const Icon(
                  Icons.favorite,
                  color: Color(0xFF1F7D53),
                ),
                onPressed: () {
                  deleteFavorites(id);
                },
                // To be implemented
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewRecipe(recipeId: recipe['id']),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
