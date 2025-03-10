import 'package:flutter/material.dart';
import 'package:user_recipeapp/main.dart';

class Favorties extends StatefulWidget {
  const Favorties({super.key});

  @override
  State<Favorties> createState() => _FavortiesState();
}

class _FavortiesState extends State<Favorties> {
 List<Map<String, dynamic>> favorites = [];


  Future <void> fetchFavorite() async {
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
          final recipe = favorites[index]['tbl_recipe'];
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: const Icon(Icons.fastfood, color: Color.fromARGB(255, 255, 220, 123),),
              title: Text(recipe['recipe_name']),
              subtitle: Text(recipe['recipe_details']),
              trailing: IconButton(
                icon: const Icon(Icons.favorite_border, color:  Color.fromARGB(255, 255, 220, 123),),
                onPressed: () {

                }, // To be implemented
              ),
            ),
          );
        },
      );
  }
}