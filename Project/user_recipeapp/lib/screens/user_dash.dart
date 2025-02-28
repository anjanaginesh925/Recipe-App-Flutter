import 'package:flutter/material.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           

            // Trending Recipes
            const Text(
              "Trending Recipes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[300], // Placeholder color
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Popular Categories
            const Text(
              "Popular Categories",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.yellow[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Follow Creators
            const Text(
              "Follow Creators",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5, // Placeholder count
                itemBuilder: (context, index) {
                  return Container(
                    width: 60,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue[300], // Placeholder color
                    ),
                    child: const Center(
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Recently Viewed Recipes
            const Text(
              "Recently Viewed Recipes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.pink[200], // Placeholder color
                    ),
                  );
                },
              ),
            ),
          ],
        );
  }
}