import 'package:flutter/material.dart';
import 'package:admin_recipeapp/main.dart'; // Assuming supabase is here
import 'package:intl/intl.dart';

class ComplaintsPage extends StatefulWidget {
  const ComplaintsPage({super.key});

  @override
  State<ComplaintsPage> createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> complaints = [];

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  Future<void> fetchComplaints() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await supabase
          .from('tbl_complaint')
          .select('''
            id, complaint_title, complaint_content, complaint_date, complaint_status, complaint_reply,
            user_id, tbl_user!user_id(user_name),
            recipe_id, tbl_recipe!recipe_id(recipe_name)
          ''')
          .order('complaint_date', ascending: false);

      final List<Map<String, dynamic>> complaintData = [];
      for (var complaint in response) {
        complaintData.add({
          'id': complaint['id'].toString(),
          'title': complaint['complaint_title'] ?? 'No Title',
          'content': complaint['complaint_content'] ?? 'No Content',
          'date': DateTime.parse(complaint['complaint_date']),
          'status': complaint['complaint_status'] == '0' ? 'Unresolved' : 'Resolved',
          'user_name': complaint['tbl_user']?['user_name'] ?? 'Unknown User',
          'recipe_name': complaint['tbl_recipe']?['recipe_name'] ?? 'Unknown Recipe',
          'reply': complaint['complaint_reply'],
        });
      }

      setState(() {
        complaints = complaintData;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching complaints: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> submitReply(String complaintId, String reply) async {
    try {
      await supabase
          .from('tbl_complaint')
          .update({
            'complaint_reply': reply,
            'complaint_status': '1', // Mark as resolved
          })
          .eq('id', complaintId);

      // Refresh the complaints list
      await fetchComplaints();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reply submitted successfully'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
    } catch (e) {
      print('Error submitting reply: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting reply: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void showReplyDialog(String complaintId, String? existingReply) {
    final TextEditingController replyController =
        TextEditingController(text: existingReply);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Reply to Complaint',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A3C34),
            ),
          ),
          content: TextField(
            controller: replyController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Enter your reply here...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2E7D32)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2E7D32)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (replyController.text.trim().isNotEmpty) {
                  submitReply(complaintId, replyController.text.trim());
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reply cannot be empty'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Submit',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Complaints',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A3C34),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage and respond to user complaints',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF2E7D32),
                  ),
                )
              : complaints.isEmpty
                  ? _buildEmptyState('No complaints available')
                  : Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 20,
                          headingRowColor: MaterialStateColor.resolveWith(
                              (states) => const Color(0xFF2E7D32).withOpacity(0.1)),
                          dataRowColor: MaterialStateColor.resolveWith(
                              (states) => Colors.white),
                          border: TableBorder(
                            horizontalInside:
                                BorderSide(color: Colors.grey.shade200),
                            verticalInside: BorderSide(color: Colors.grey.shade200),
                            top: BorderSide(color: Colors.grey.shade200),
                            bottom: BorderSide(color: Colors.grey.shade200),
                            left: BorderSide(color: Colors.grey.shade200),
                            right: BorderSide(color: Colors.grey.shade200),
                          ),
                          columns: const [
                            DataColumn(
                              label: Text(
                                'Complaint ID',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A3C34),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Title',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A3C34),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Content',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A3C34),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Date',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A3C34),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Status',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A3C34),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'User',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A3C34),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Recipe',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A3C34),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Action',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A3C34),
                                ),
                              ),
                            ),
                          ],
                          rows: complaints.map((complaint) {
                            return DataRow(cells: [
                              DataCell(
                                Text(
                                  complaint['id'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF1A3C34),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  complaint['title'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF1A3C34),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              DataCell(
                                Text(
                                  complaint['content'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF1A3C34),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              DataCell(
                                Text(
                                  DateFormat('MMM dd, yyyy')
                                      .format(complaint['date']),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF1A3C34),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  complaint['status'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: complaint['status'] == 'Unresolved'
                                        ? Colors.red
                                        : const Color(0xFF2E7D32),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  complaint['user_name'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF1A3C34),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  complaint['recipe_name'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF1A3C34),
                                  ),
                                ),
                              ),
                              DataCell(
                                ElevatedButton(
                                  onPressed: () {
                                    showReplyDialog(
                                        complaint['id'], complaint['reply']);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2E7D32),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                  ),
                                  child: Text(
                                    complaint['reply'] == null ? 'Reply' : 'View Reply',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
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
}