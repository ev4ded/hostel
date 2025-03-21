import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:minipro/warden/services/FCMservices.dart';

class Maintenance extends StatefulWidget {
  const Maintenance({super.key});

  @override
  _MaintenanceState createState() => _MaintenanceState();
}

class _MaintenanceState extends State<Maintenance>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? hostelId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchHostelId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            "Maintenance Requests",
             style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          bottom: _buildTabBar(),
            backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        ),
      body: hostelId == null
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                RequestsList(status: "Pending", hostel_id: hostelId!),
                RequestsList(status: "Approved", hostel_id: hostelId!),
                RequestsList(status: "Denied", hostel_id: hostelId!),
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
        Tab(
            child: Text(
          "Pending",
          style: GoogleFonts.dmSans(),
        )),
        Tab(child: Text("Approved", style: GoogleFonts.dmSans())),
        Tab(child: Text("Denied", style: GoogleFonts.dmSans())),
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
          .collection("maintenance_request")
          .where("hostel_id", isEqualTo: hostel_id)
          .where("status", isEqualTo: status.toLowerCase())
          .orderBy("created_at", descending: true)
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
                title: Text(requestData["title"] ?? "No Title",
                    style: GoogleFonts.inder(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      "Room No: ${requestData["room_no"] ?? "No Room No"}",
                      style: GoogleFonts.inter(fontWeight: FontWeight.w400),
                    ),
                    Text(
                        "Description: ${requestData["description"] ?? "No Description"}",
                        style: GoogleFonts.inter(fontWeight: FontWeight.w400)),
                  ],
                ),
                trailing: status == "Pending"
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              DateTime? selectedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2070),
                              );

                              if (selectedDate == null) return;

                              TimeOfDay? selectedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );

                              if (selectedTime == null) {
                                return; // User canceled the time picker
                              }
                              TimeOfDay minTime =
                                  TimeOfDay(hour: 9, minute: 0); // 9:00 AM
                              TimeOfDay maxTime =
                                  TimeOfDay(hour: 17, minute: 0); // 5:00 PM

                              // Validate time selection
                              if (selectedTime.hour < minTime.hour ||
                                  (selectedTime.hour == minTime.hour &&
                                      selectedTime.minute < minTime.minute)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "My guy select a time after 9:00 AM.")),
                                );
                                return;
                              } else if (selectedTime.hour > maxTime.hour ||
                                  (selectedTime.hour == maxTime.hour &&
                                      selectedTime.minute > maxTime.minute)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "My guy select a time before 5:00 PM.")),
                                );
                                return;
                              }
                              String formattedDateTime =
                                  "${selectedDate.year}-${selectedDate.month}-${selectedDate.day} "
                                  "${selectedTime.hour}:${selectedTime.minute}:00";

                              updateStatus(requestId, "Approved",
                                  formattedDateTime, context);
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green),
                            child: Text("Approve",
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w500)),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () => updateStatus(requestId, "Denied",
                                "approvedDateTime", context),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            child: Text(
                              "Deny",
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      )
                    : Icon(
                        status == "Approved"
                            ? Ionicons.checkmark_circle_outline
                            : Ionicons.close_circle_outline,
                        color: status == "Approved" ? Colors.green : Colors.red,
                        size: 30,
                      ),
              ),
            );
          },
        );
      },
    );
  }

  void updateStatus(String requestId, String newStatus,
      String formattedDateTime, BuildContext context) async {
    try {
      final maintenanceRef =
          _firestore.collection("maintenance_request").doc(requestId);
      final maintenanceSnapshot = await maintenanceRef.get();

      if (!maintenanceSnapshot.exists) {
        print("❌ Complaint not found!");
        return;
      }

      final maintenanceData = maintenanceSnapshot.data();
      final studentUid = maintenanceData?["student_id"];
      final maintenanceTitle =
          maintenanceData?["title"] ?? "Maintenance Update";

      if (studentUid == null) {
        print("❌ Student ID not found in complaint data!");
        return;
      }

      final studentDoc =
          await _firestore.collection("users").doc(studentUid).get();

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
      await maintenanceRef.update({
        "status": newStatus.toLowerCase(),
      });
      String notificationBody;
      if (newStatus.toLowerCase() == "approved") {
        await maintenanceRef.update({"approvedDateTime": formattedDateTime});
        notificationBody =
            "Your maintenance request has been approved and scheduled for $formattedDateTime.";
      } else {
        notificationBody =
            "Your maintenance request status has been  $newStatus.";
      }
      // ✅ Send Notification
      for (var token in fcmTokens) {
        await FCMService.sendNotification(
          fcmToken: token,
          title: "Maintenance Update: $maintenanceTitle",
          body: notificationBody,
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
