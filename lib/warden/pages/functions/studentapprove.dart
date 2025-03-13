import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minipro/warden/wardenQueries/queries.dart';

class StudentApproval extends StatefulWidget {
  const StudentApproval({super.key});

  @override
  _StudentApprovalState createState() => _StudentApprovalState();
}

class _StudentApprovalState extends State<StudentApproval> {
  String? hostelId;

  @override
  void initState() {
    super.initState();
    _fetchHostelId();
  }

  void _fetchHostelId() async {
    String? fetchedHostelId = await fetchHostelId();
    if (fetchedHostelId != null) {
      setState(() {
        hostelId = fetchedHostelId;
      });
      debugPrint("🏠 Found Hostel ID: $hostelId");
    } else {
      debugPrint("❌ Could not fetch Hostel ID.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student Approval", style: GoogleFonts.inter()),
      ),
      body: hostelId == null
          ? Center(child: CircularProgressIndicator())
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
          .where("hostelId", isEqualTo: hostelId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No Pending Student Approvals", style: GoogleFonts.poppins()));
        }

        var requests = snapshot.data!.docs;

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            var student = requests[index];
            Map<String, dynamic> studentData = student.data() as Map<String, dynamic>;
            String studentId = student.id;
            String studentName = studentData["username"] ?? "Unknown";

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Container(
                padding:EdgeInsets.symmetric(vertical:12),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: CircleAvatar(
                    radius: 24,
                    child: Text(studentName[0].toUpperCase(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  title: Text("Name: $studentName", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _actionButton(context, "Approve", Colors.green, () => _approveStudent(studentId, context)),
                      SizedBox(width: 8),
                      _actionButton(context, "Deny", Colors.red, () => _denyStudent(studentId, context)),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// ✅ Generic Action Button
  Widget _actionButton(BuildContext context, String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: color, padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
      child: Text(text, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14)),
    );
  }

  /// ✅ Approve Student & Assign Room
  void _approveStudent(String studentId, BuildContext context) async {
    String? newRoom = await _selectRoom(context);
    if (newRoom == null || newRoom.isEmpty) return;

    try {
      await _firestore.collection("users").doc(studentId).update({
        "isApproved": true,
        "room_no": newRoom,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Student Approved & Room Assigned!", style: GoogleFonts.poppins())));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $error", style: GoogleFonts.poppins())));
    }
  }

  /// ❌ Deny Student & Provide Reason
  void _denyStudent(String studentId, BuildContext context) async {
    String reason = await _getDenialReason(context);
    if (reason.isEmpty) return;

    try {
      await _firestore.collection("users").doc(studentId).update({
        "isApproved": false,
        "reason": reason,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Student Denied!", style: GoogleFonts.poppins())));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $error", style: GoogleFonts.poppins())));
    }
  }

  /// 📌 Dialog for Room Selection
  Future<String?> _selectRoom(BuildContext context) async {
    TextEditingController roomController = TextEditingController();

    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Assign Room", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: roomController,
          decoration: InputDecoration(hintText: "Enter Room No"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, null), child: Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, roomController.text), child: Text("OK")),
        ],
      ),
    );
  }

  /// 📌 Dialog for Denial Reason
  Future<String> _getDenialReason(BuildContext context) async {
    TextEditingController reasonController = TextEditingController();

    return await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Denial Reason", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            content: TextField(
              controller: reasonController,
              decoration: InputDecoration(hintText: "Enter Reason"),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, ""), child: Text("Cancel")),
              TextButton(onPressed: () => Navigator.pop(context, reasonController.text), child: Text("Submit")),
            ],
          ),
        ) ??
        "";
  }
}
