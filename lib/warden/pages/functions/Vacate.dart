import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minipro/warden/services/FCMservices.dart';
import 'package:minipro/warden/wardenQueries/queries.dart';

class VacateRequest extends StatefulWidget {
  const VacateRequest({super.key});

 

  @override
  _VacateRequestState createState() => _VacateRequestState();
}

class _VacateRequestState extends State<VacateRequest> {
  String? hostelId;

  @override
  void initState() {
    super.initState();
    _fetchHostelId();
  }

  // Fetch warden's hostel ID
  void _fetchHostelId() async {
    String? fetchedHostelId = await fetchHostelId(); // Implement this function
    if (fetchedHostelId != null) {
      setState(() {
        hostelId = fetchedHostelId;
      });
    }
  }

  // Show confirmation dialog
  void _showConfirmationDialog(String requestId, String newStatus,
      String studentId, String studentName) {
    showConfirmationDialog(
      context: context,
      title: newStatus == "approved" ? "Approve Request" : "Deny Request",
      message:
          "Are you sure you want to approve the vacate request for $studentName?",
      confirmText: newStatus,
      confirmColor: newStatus == "approved" ? Colors.green : Colors.red,
      onConfirm: () => _updateRequestStatus(requestId, newStatus, studentId),
    );
  }

  // Update request status (approve/deny)
    void _updateRequestStatus(
      String requestId, String newStatus, String studentId) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      await FirebaseFirestore.instance
          .collection('vacate')
          .doc(requestId)
          .update({"status": newStatus});

      if (newStatus == "approved") {
        await removeStudent(studentId, hostelId!);
        await FirebaseFirestore.instance
            .collection('vacate')
            .doc(requestId)
            .delete();
      }

      final studentDoc = await FirebaseFirestore.instance.collection("users").doc(studentId).get();
      final fcmTokens = studentDoc["FCM_tokens"] ?? [""];
      if (fcmTokens.isEmpty) {
         String notificationBody = "Your vacate request has been $newStatus.";
       
        for (var token in fcmTokens) {
          await FCMService.sendNotification(
            fcmToken: token,
            title: "Vacate Request Update",
            body: notificationBody,
          );
        }
         print("❌ No FCM tokens found for the student!");
        return;
      }

      if (fcmTokens.isNotEmpty) {
        String notificationBody = "Your vacate request has been updated to $newStatus.";
        for (var token in fcmTokens) {
          await FCMService.sendNotification(
            fcmToken: token,
            title: "Vacate Request Update",
            body: notificationBody,
          );
        }
      }

      if (mounted) Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Vacate request $newStatus."),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error: Unable to update request"),
            backgroundColor: Colors.red),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Vacate Requests",
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
      ),
      body: hostelId == null
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('vacate')
                  .where('hostel_id', isEqualTo: hostelId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
            child:
          Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/warden/caughtup.png', // Add an appropriate empty state image
            height: 200,
          ),
          
           Text("No pending Requests Found")],),
    );
                }

                var requests = snapshot.data!.docs;
                if (requests.isEmpty) {
                  return Center(child: Text("No pending vacate requests."));
                }

                return ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    var request = requests[index];
                    var requestData = request.data() as Map<String, dynamic>;

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.blue.shade100],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                        child: ListTile(
                          title: Text(requestData['name'],
                              style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Room: ${requestData['room_no']}',style:GoogleFonts.inter(color:  Colors.black) ,),
                              Text('Reason: ${requestData['reason']}',style:GoogleFonts.inter(color:  Colors.black)),
                              Text('Date: ${requestData['vacting_date']}',style:GoogleFonts.inter(color:  Colors.black)),
                            
                             ],
                             ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _showConfirmationDialog(
                                  request.id,
                                  "approved",
                                  requestData['student_id'] ?? "",
                                  requestData['name'] ?? "",
                                ),
                                icon: Icon(Icons.check),
                                label: Text("Approve"),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
