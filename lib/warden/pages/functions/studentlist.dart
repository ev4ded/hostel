import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Space between rows
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey, size: 22), // Icon with color
          SizedBox(width: 8), // Space between icon & text
          Expanded(
            child: Text(
              '$label: $value',
              style:GoogleFonts.inter(fontSize: 16,fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis, // Prevents overflow
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
   someFunction();
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

  void _showStudentBottomSheet(BuildContext context, Map<String, dynamic> student,String docId) {
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
              _buildInfoRow(Ionicons.calendar_clear_outline, 'Present', student['present'] == true ? 'Yes' : 'No'),
              SizedBox(height: 10),
             Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Space buttons evenly
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Close'),
                    ),
                  ),
                  SizedBox(width: 10), // Spacing between buttons
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async { 
                       
                        await removeStudent(docId,hostelId!); // Pass the hostelId here
                        Navigator.pop(context);
                      },

                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red), // Optional: Red color for "Remove"
                      child: Text('Remove'),
                    ),
                  ),
                ],
              ),

            ],
          ),
        )
          );
      },
    );
   } );
  
  }
  

  Future<void> updatePayment() async {
  try {
    String? hostelId = await fetchHostelId(); // Fetch the hostel ID dynamically
    if (hostelId == null) {
      debugPrint("❌ Hostel ID not found.");
      return;
    }

    await FirebaseFirestore.instance.collection("hostels").doc(hostelId).update({
      "paymentTime": true,
    });

    debugPrint("✅ Payment Time set to true.");
    
    // Show a success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment Time Set!"), backgroundColor: Colors.green),
      );
    }
  } catch (e) {
    debugPrint("❌ Error updating paymentTime: $e");
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update payment time!"), backgroundColor: Colors.red),
      );
    }
  }
}


 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Student Listing', style: GoogleFonts.inter(fontWeight: FontWeight.w600)), 
       backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,),
      body: (hostelId == null)
        ? Center(child: CircularProgressIndicator()) 
      : Column(
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
                  .where('role', isEqualTo: 'student')
                  .where('hostelId',isEqualTo:hostelId )
                  .where('isApproved', isEqualTo: true)
                  .where('profileUpdated', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
                var students = snapshot.data!.docs.where((doc) {
                  var name = doc['username'].toString().toLowerCase();
                   
                   
                  return name.contains(searchQuery);
                })
                .toList();

                return ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    var student = students[index];
                    String docId = student.id; // Get the document ID

                    return Card(
                       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        onTap: () => _showStudentBottomSheet(context, student.data() as Map<String, dynamic>,docId), // Open Bottom Sheet
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color.fromARGB(255, 47, 240, 92),
                          foregroundColor: Colors.black,
                          child: Text(
                            student['username'][0].toUpperCase(),
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Row(
                            children: [
                              Text(
                                student['username'],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 8), // Spacing
                              Icon(
                                student['present'] == false? Icons.circle : Icons.circle, 
                                color: student['present'] == false ?   Colors.red:Colors.green, 
                                size: 12, // Small indicator
                              ),
                            ],
                          ),
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

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
    await updatePayment();
  },
 
        label: Text("Ask Payment"),
        icon: Icon(Ionicons.save),
        backgroundColor: Colors.green,
      ),
    );
    
  }
 
}
