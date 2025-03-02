import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:minipro/warden/services/FCMservices.dart';


class Complaints extends StatefulWidget {
  const Complaints({super.key});

  @override
  _ComplaintsState createState() => _ComplaintsState();
}

class _ComplaintsState extends State<Complaints>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? hostelId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchHostelId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Complaints",style: GoogleFonts.inter(),), bottom: _buildTabBar()),
      body: hostelId == null
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                RequestsList(status: "Pending", hostel_id: hostelId!),
                RequestsList(status: "Resolved", hostel_id: hostelId!),
             ],
            ),
    );
  }

  PreferredSizeWidget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: const Color.fromARGB(255, 250, 244, 244).withRed(3),
      unselectedLabelColor: Color(0xFFDCC8C8),
      indicatorColor: const Color.fromARGB(255, 250, 244, 244).withRed(3),
      indicatorWeight: 3,
      tabs: [
         Tab(child:Text( "Pending",style: GoogleFonts.dmSans(),)),
         Tab(child:Text( "Resolved",style: GoogleFonts.dmSans(),)),
       // Tab(text: "Denied"),
      ],
    );
  }

  Future<void> fetchHostelId() async {
    try {
      User? user = FirebaseAuth.instance.currentUser; // Get logged-in user
      if (user == null) {
        debugPrint("⚠️ No user is logged in.");
        return;
      }
      debugPrint("✅ Logged-in user: ${user.email}");

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: user.email) // Fetch warden by email
          .where("role", isEqualTo: "warden")
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          hostelId = snapshot.docs.first["hostelId"];
        });
        debugPrint("🏠 Hostel ID fetched: $hostelId");
      } else {
        debugPrint("⚠️ No hostel found for this warden.");
      }
    } catch (e) {
      debugPrint("❌ Error fetching hostel ID: $e");
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class RequestsList extends StatelessWidget {
  final String status;
  final String hostel_id;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RequestsList({super.key, required this.status, required this.hostel_id});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection("complaints")
          .where("hostel_id", isEqualTo: hostel_id)
          .where("status", isEqualTo: status.toLowerCase())
          //.orderBy("created_at", descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint("Firestore Error: ${snapshot.error}");
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No $status Requests Found"));
        }

        var requests = snapshot.data!.docs;
        debugPrint("Fetched ${requests.length} documents");

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            var request = requests[index];
            Map<String, dynamic> requestData =
                request.data() as Map<String, dynamic>;
            String requestId = requestData["request_id"] ?? request.id;

            return Card(
              margin: EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(requestData["title"] ?? "No Title", style: GoogleFonts.inder(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Text("Room No: ${requestData["room_no"] ?? "No Room No"}", style:GoogleFonts.inter(fontWeight: FontWeight.w400)),
                    Text("Description: ${requestData["description"] ?? "No Description"}", style:GoogleFonts.inter(fontWeight: FontWeight.w400)),
                    Text("Priority: ${requestData["priority"] ?? "No Priority"}", style:GoogleFonts.inter(fontWeight: FontWeight.w400)),
                  ],
                ),
                trailing: status == "Pending"
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () => updateStatus(requestId, "Resolved" ,context,),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            child: Text("Resolve",style: GoogleFonts.inter(fontWeight: FontWeight.w500),),
                          ),
                        ],
                      )
                    : Icon(
                        Ionicons.checkmark_circle_outline,
                        color: Colors.green,
                        size: 30,
                      ),
              ),
            );
          },
        );
      },
    );
  }

 void updateStatus(String requestId, String newStatus, BuildContext context) async {
  try {
    final complaintRef = _firestore.collection("complaints").doc(requestId);
    final complaintSnapshot = await complaintRef.get();

    if (!complaintSnapshot.exists) {
      print("❌ Complaint not found!");
      return;
    }

    final complaintData = complaintSnapshot.data();
    final studentUid = complaintData?["student_id"];
    final complaintTitle = complaintData?["title"] ?? "Complaint Update";

    if (studentUid == null) {
      print("❌ Student ID not found in complaint data!");
      return;
    }

    final studentDoc = await _firestore.collection("users").doc(studentUid).get();

    if (!studentDoc.exists) {
      print("❌ Student not found in users collection!");
      return;
    }

    final fcmTokens = studentDoc["FCM_tokens"] ?? [];
    if (fcmTokens.isEmpty) {
      print("❌ No FCM tokens found for the student!");
      return;
    }

    // ✅ Update Firestore: Mark complaint as Resolved
    await complaintRef.update({"status": newStatus.toLowerCase()});

    // ✅ Send Notification
     for (var token in fcmTokens) {
      await FCMService.sendNotification(
        fcmToken: token,
        title: "Complaint Update: $complaintTitle",
        body: "Your complaint has been marked as $newStatus.",
      );
    }

    // ✅ Show success message
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Status updated to $newStatus")));
  } catch (e) {
    print("❌ Error updating status: $e");
  }
}
}