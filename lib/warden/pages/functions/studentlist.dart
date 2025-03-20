import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:minipro/warden/wardenQueries/queries.dart';

class StudentList extends StatefulWidget {
  const StudentList({super.key});

  @override
  _StudentListState createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  String? hostelId;
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4), // Space between rows
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey, size: 20), // Icon with color
          SizedBox(width: 8), // Space between icon & text
          Expanded(
            child: Text(
              '$label: $value',
              style: TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis, // Prevents overflow
            ),
          ),
        ],
      ),
    );
  }

  void _showStudentBottomSheet(BuildContext context, Map<String, dynamic> student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
       return DraggableScrollableSheet(
        initialChildSize: 0.4,  // Opens at 40% of screen height
        minChildSize: 0.3,      // Can shrink to 30% of screen height
        maxChildSize: 0.6,      // Can expand to 60% of screen height
        expand: false,          // Prevents full-screen takeover
        builder: (context, scrollController) {
          return Padding(
            padding: EdgeInsets.all(16),
            child: SingleChildScrollView(
              controller: scrollController, // Allows scrolling within the sheet
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      student['username'],
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
              
                
              
              Divider(),
              _buildInfoRow(Ionicons.mail_unread_outline, 'Email', student['email']),
              _buildInfoRow(Ionicons.call_outline, 'Phone', student['phone_no']),
              _buildInfoRow(Icons.cake_outlined, 'Date of Birth', student['dob']),
              _buildInfoRow(Ionicons.school, 'College', student['college_name']),
              _buildInfoRow(Ionicons.book, 'Course', student['degree']),
              _buildInfoRow(Ionicons.calendar_clear_outline, 'Year', student['year_of_study']),
              SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close'),
                ),
              ),
            ],
          ),
        )
          );
      },
    );
   } );
  
  }

   @override
  void initState() {
    super.initState();
   someFunction();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Student Listing')),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Material(
              elevation: 3, // Adds shadow effect
              borderRadius: BorderRadius.circular(30), // Makes it curved
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search Student',
                  prefixIcon: Icon(Ionicons.search,size:25 , color: Colors.grey.shade600),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30), // Curved edges
                    borderSide: BorderSide.none, // No default border
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 14), // Adjust height
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
            
          ),
          

          // Student List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('hostelId',isEqualTo:hostelId )
                  .where('role', isEqualTo: 'student')
                  .where('isApproved', isEqualTo: true)
                  .where('profileUpdated', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                var students = snapshot.data!.docs.where((doc) {
                  var name = doc['username'].toString().toLowerCase();
                  return name.contains(searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    var student = students[index];

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        onTap: () => _showStudentBottomSheet(context, student.data() as Map<String, dynamic>), // Open Bottom Sheet
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color.fromARGB(255, 47, 240, 92),
                          foregroundColor: Colors.black,
                          child: Text(
                            student['username'][0].toUpperCase(),
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(student['username'], style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Room: ${student['room_no']}'),
                        trailing: Icon(Ionicons.chevron_forward_outline, size: 30, color: Colors.grey),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
    
  }
  void someFunction() async {
  String? fetchedHostelId = await fetchHostelId();
  if (fetchedHostelId != null) {
    setState(() {
      hostelId = fetchedHostelId; // ✅ Update state
    });
    debugPrint("🏠 Found Hostel ID: $hostelId");
  } else {
    debugPrint("❌ Could not fetch Hostel ID.");
  }
}
}
