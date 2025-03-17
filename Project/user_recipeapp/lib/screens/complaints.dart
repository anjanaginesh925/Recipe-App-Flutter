import 'package:flutter/material.dart';
import 'package:user_recipeapp/main.dart';

class Complaints extends StatefulWidget {
  final int recipeId;

  const Complaints({super.key, required this.recipeId});

  @override
  State<Complaints> createState() => _ComplaintsState();
}

class _ComplaintsState extends State<Complaints> {
  int _rating = 0;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _complaintController = TextEditingController();

  Future<void> submitReviewAndComplaint() async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to submit a  complaint.')),
      );
      return;
    }

    if ((_titleController.text.isEmpty && _complaintController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a  complaint.')),
      );
      return;
    }

    try {
      // Insert review if provided
      if (_titleController.text.isNotEmpty) {
        await supabase.from('tbl_complaint').insert({
          'complaint_title': _titleController.text,
          'complaint_content': _complaintController.text,
          'user_id': userId,
          'recipe_id': widget.recipeId,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your complaint has been submitted!')),
      );

      // Clear the fields
      _titleController.clear();
      _complaintController.clear();
      setState(() => _rating = 0);
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complaints')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Title:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: _titleController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Add Complaint Title...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Write a Complaint:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: _complaintController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe your complaint...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
           Center(
             child: SizedBox(
               width: 200, // Adjust this value as needed
               child: ElevatedButton(
                 onPressed: submitReviewAndComplaint,
                 style: ElevatedButton.styleFrom(
                   backgroundColor: const Color(0xFF1F7D53), // Dark blue color
                   foregroundColor: Colors.white, // Text color
                   minimumSize: const Size(50, 50), // Adjust width and height
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(20), // Rounded corners
                   ),
                 ),
                 child: const Text("Submit"),
               ),
             ),
           ),


            const SizedBox(height: 20),
            // You can also add any additional UI elements, like a status or info section
          ],
        ),
      ),
    );
  }
}
