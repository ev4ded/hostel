//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minipro/warden/services/FCMservices.dart';
import 'package:minipro/warden/wardenQueries/queries.dart';


class RoomChange extends StatefulWidget {
  const RoomChange({super.key});

  @override
  _RoomChangeState createState() => _RoomChangeState();
}

class _RoomChangeState extends State<RoomChange> {
  String? hostelId;
 // String? wardenRoomNo;

  @override
  void initState() {
    super.initState();
   someFunction();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Room Change Requests",  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
      ),
      body: hostelId == null
          ? Center(child: CircularProgressIndicator())
          : RequestsList(hostelId: hostelId!),
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

class RequestsList extends StatelessWidget {
  final String hostelId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RequestsList({super.key, required this.hostelId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection("room_change")          
          .where("status", isEqualTo: "pending")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No Pending Requests Found"));
        }

        var requests = snapshot.data!.docs;

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            var request = requests[index];
            Map<String, dynamic> requestData = request.data() as Map<String, dynamic>;
            String studentId = request.id;
           

           return FutureBuilder<DocumentSnapshot>(
          future: _firestore.collection("users").doc(request.id).get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(); // Avoid unnecessary UI updates while loading
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return SizedBox();
            }

            var userData = userSnapshot.data!.data() as Map<String, dynamic>;

            if (userData["hostelId"] != hostelId) {
              return SizedBox(); // Ignore requests from other hostels
            }
                String studentName = userData["username"] ?? "Unknown";
                String currentRoom = userData["room_no"] ?? "Not Assigned";
                
            return Card(
              margin: EdgeInsets.all(8.0),
              child: ListTile(
                 title: Text("$studentName (Room: $currentRoom)", style: GoogleFonts.inter()),
                    subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Text("Request: ${requestData['description']}"),
                    
                    ]
                  ),
                           
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () => approveRequest( studentId, context),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: Text("Approve", style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => denyRequest(studentId, context),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: Text("Deny", style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  
  }
  );
  }
  
Future<void> approveRequest(String studentId, BuildContext context) async {
  if (!context.mounted) return;  // ✅ Prevent error if widget is deactivated

  String? newRoom = await selectRoom(context);
  if (newRoom == null || newRoom.isEmpty) return;

  try {
    DocumentSnapshot studentDoc =
        await FirebaseFirestore.instance.collection("users").doc(studentId).get();

    if (!studentDoc.exists) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Student not found!")));
      }
      return;
    }

    await FirebaseFirestore.instance.collection("room_change").doc(studentId).update({
      "status": "approved",
      "approved_room": newRoom,
    });

    await FirebaseFirestore.instance.collection("users").doc(studentId).update({
      "room_no": newRoom,
    });

    List<String> fcmToken = (studentDoc["FCM_tokens"] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

   if (fcmToken.isNotEmpty) {
      print("✅ Sending FCM Notification...");
      await FCMService.sendNotification(
        fcmToken: fcmToken,
        title: "Room Change Approved",
        body: "Your room change request has been approved! Your new room is $newRoom.",
      );

     
    }

    if (context.mounted) {  // ✅ Ensure context is valid
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Room changed successfully!"), backgroundColor: Colors.green),
      );
    }
  } catch (e) {
    debugPrint("❌ Error updating room: $e");
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error updating room!")));
    }
  }
}


void denyRequest(String studentId, BuildContext context) async {
  if (!context.mounted) return;  // ✅ Prevent error if widget is deactivated

  String reason = await getDenialReason(context);
  if (reason.isEmpty) return;

  DocumentSnapshot studentDoc =
      await FirebaseFirestore.instance.collection("users").doc(studentId).get();
  List<String> fcmToken = (studentDoc["FCM_tokens"] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
      [];

  if (!studentDoc.exists) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Student not found!")));
    }
    return;
  }

  await FirebaseFirestore.instance.collection("room_change").doc(studentId).update({
    "status": "denied",
    "reason": reason,
  });

  if (fcmToken.isNotEmpty) {
    print("✅ Sending FCM Notification...");
    await FCMService.sendNotification(
      fcmToken: fcmToken,
      title: "Room Change Denied",
      body: "Your room change request has been denied. Reason: $reason",
    );

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Request denied!")));
  }
}

}
}