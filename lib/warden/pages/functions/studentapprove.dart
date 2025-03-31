import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minipro/warden/services/FCMservices.dart';
import 'package:minipro/warden/wardenQueries/queries.dart';

class StudentApproval extends StatefulWidget {
  const StudentApproval({super.key});

  @override
  _StudentApprovalState createState() => _StudentApprovalState();
}

class _StudentApprovalState extends State<StudentApproval> {
  String? hostelId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHostelId();
  }

  void _fetchHostelId() async {
    try {
      String? fetchedHostelId =
          await fetchHostelId(); // Assuming this method exists
      if (fetchedHostelId != null) {
        setState(() {
          hostelId = fetchedHostelId;
          _isLoading = false;
        });
      } else {
        _showErrorDialog('Unable to fetch Hostel Information');
      }
    } catch (e) {
      _showErrorDialog('Error: ${e.toString()}');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(message, style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: GoogleFonts.poppins()),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student Approval",
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: Colors.indigo.shade700,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.indigo.shade700),
              ),
            )
          : StudentRequestsList(hostelId: hostelId!),
    );
  }
}

class StudentRequestsList extends StatelessWidget {
  final String hostelId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StudentRequestsList({super.key, required this.hostelId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection("users")
          .where("isApproved", isEqualTo: false)
          .where("role", isEqualTo: "student")
          .where("hostelId", isEqualTo: hostelId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo.shade700),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyStateWidget(context);
        }

        var requests = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            var student = requests[index];
            Map<String, dynamic> studentData =
                student.data() as Map<String, dynamic>;
            String studentId = student.id;
            String studentName = studentData["username"] ?? "Unknown Student";

            return _buildStudentRequestCard(context, studentId, studentName);
          },
        );
      },
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 60),
          Text(
            'Something went wrong',
            style:
                GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          Text(
            error,
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/warden/caughtup.png', // Add an appropriate empty state image
            height: 200,
          ),
          Text(
            "No Pending Student Approvals",
            style:
                GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 10),
          Text(
            "All students are currently approved or no new requests",
            style: GoogleFonts.poppins(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStudentRequestCard(
      BuildContext context, String studentId, String studentName) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      gradient: LinearGradient(
        colors: [Colors.white, Colors.blue.shade100],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.indigo.shade100,
                child: Text(
                  studentName[0].toUpperCase(),
                  style: TextStyle(
                      color: Colors.indigo.shade700,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      studentName,
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.w600,color: Colors.black),
                    ),
                    Text(
                      'Pending Approval',
                      style:
                          GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _buildActionButton(context, "Approve", Colors.green,
                      () => approveStudent(studentId, hostelId, context)),
                  const SizedBox(width: 8),
                  _buildActionButton(context, "Deny", Colors.red,
                      () => denyStudent(studentId, context)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void approveStudent(String studentId, String hostelId, BuildContext context) async {
  try {
    String? selectedRoomNumber = await _showRoomSelectionDialog(context, hostelId);

    if (selectedRoomNumber == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Room selection cancelled")));
      return;
    }

    DocumentReference roomRef = _firestore
        .collection("hostels")
        .doc(hostelId)
        .collection("rooms")
        .doc(selectedRoomNumber);

    DocumentSnapshot roomSnapshot = await roomRef.get();

    if (roomSnapshot.exists) {
      await roomRef.update({
        "occupants": FieldValue.arrayUnion([studentId])
      });
    } else {
      await roomRef.set({
        "occupants": [studentId],
        "room_no": selectedRoomNumber
      });
    }

    await _firestore.collection("users").doc(studentId).update({
      "room_no": selectedRoomNumber,
      "isApproved": true,
    });

    DocumentSnapshot studentDoc = await _firestore.collection("users").doc(studentId).get();
    List<String> fcmTokens = List<String>.from(studentDoc["FCM_tokens"] ?? [""]);
     if (fcmTokens.isEmpty) {
      await _firestore.collection("users").doc(studentId).update({
      "room_no": selectedRoomNumber,
      "isApproved": true,
    });
      print("❌ No FCM tokens found for the student!");
      return;
    }
    for (var token in fcmTokens) {
      await FCMService.sendNotification(
        fcmToken: token,
        title: "Approval Notification",
        body: "Your hostel admission has been approved! Room: $selectedRoomNumber",
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Student Approved & Room Assigned")));
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error approving student: $error")));
  }
}

void denyStudent(String studentId, BuildContext context) async {
  try {
    DocumentSnapshot studentDoc = await _firestore.collection("users").doc(studentId).get();
    List<String> fcmTokens = List<String>.from(studentDoc["FCM_tokens"] ?? [""]);
    if (fcmTokens.isEmpty) {
        await _firestore.collection("users").doc(studentId).delete();
      print("❌ No FCM tokens found for the student!");
      return;
    }

    await _firestore.collection("users").doc(studentId).delete();

    for (var token in fcmTokens) {
      await FCMService.sendNotification(
        fcmToken: token,
        title: "Denial Notification",
        body: "Your hostel admission request has been denied.",
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Student Denied!")));
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error")));
  }
}


  Widget _buildActionButton(
      BuildContext context, String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(text,
          style:
              GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
    );
  }

  Future<String?> _showRoomSelectionDialog(
      BuildContext context, String hostelId) async {
    // Retrieve hostel and room details
    DocumentSnapshot hostelSnapshot =
        await _firestore.collection("hostels").doc(hostelId).get();
    Map<String, dynamic> hostelData =
        hostelSnapshot.data() as Map<String, dynamic>;
    int totalRooms = hostelData["no_of_room"];
    int capacity = hostelData["capacity"];

    // Fetch room occupancy data
    QuerySnapshot occupantsSnapshot = await _firestore
        .collection("hostels")
        .doc(hostelId)
        .collection("rooms")
        .get();

    Map<String, int> roomOccupantsCount = {};
    for (var doc in occupantsSnapshot.docs) {
      String roomId = doc.id;
      Map<String, dynamic> roomData = doc.data() as Map<String, dynamic>;
      List<dynamic> occupants =
          roomData.containsKey("occupants") ? roomData["occupants"] : [];
      roomOccupantsCount[roomId] = occupants.length;
    }

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (_, controller) => Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Select Room',
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  controller: controller,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: totalRooms,
                  itemBuilder: (context, index) {
                    String roomId = (index + 1).toString();
                    int occupants = roomOccupantsCount[roomId] ?? 0;
                    bool isFull = occupants >= capacity;

                    return GestureDetector(
                      onTap:
                          isFull ? null : () => Navigator.pop(context, roomId),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isFull
                              ? Colors.red.shade100
                              : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: isFull
                                  ? Colors.red.shade300
                                  : Colors.green.shade300,
                              width: 2),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Room $roomId',
                              style: GoogleFonts.poppins(
                                  color: isFull
                                      ? Colors.red.shade700
                                      : Colors.green.shade700,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
