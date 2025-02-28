import 'package:flutter/material.dart';

class Favorties extends StatelessWidget {
  const Favorties({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
        itemCount: 5, // Placeholder for now
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: const Icon(Icons.fastfood, color: const Color.fromARGB(255, 255, 220, 123),),
              title: Text("Recipe ${index + 1}"),
              subtitle: const Text("A delicious recipe"),
              trailing: IconButton(
                icon: const Icon(Icons.favorite_border, color:  const Color.fromARGB(255, 255, 220, 123),),
                onPressed: () {}, // To be implemented
              ),
            ),
          );
        },
      );
  }
}