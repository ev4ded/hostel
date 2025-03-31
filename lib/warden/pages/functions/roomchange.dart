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
      appBar: AppBar(title: Text("Room Change Requests",style: GoogleFonts.inter(fontWeight: FontWeight.w600,color: Colors.white)),
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
          return Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hourglass_empty, size: 50, color: Colors.grey),
              Text("No Pending Requests Found"),
            ],
          ));
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
  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  elevation: 5,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
  ),
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
    child: Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.white,
          backgroundImage: AssetImage('assets/images/profile/${userData['dp']}.jpg'),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                studentName,
                style: GoogleFonts.poppins(color: Colors.black,fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                "Room: $currentRoom",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade700),
              ),
              SizedBox(height: 8),
              Text(
                "Request: ${requestData['description']}",
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade800),
              ),
            ],
          ),
        ),
        Column(
          children: [
            ElevatedButton.icon(
              onPressed: () => approveRequest(studentId, context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              icon: Icon(Icons.check, color: Colors.white, size: 18),
              label: Text("Approve", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
            ),
            SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => denyRequest(studentId, context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              icon: Icon(Icons.close, color: Colors.white, size: 18),
              label: Text("Deny", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
            ),
          ],
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

  Future<String?> _showRoomSelectionDialog(BuildContext context, String hostelId) async {
    // Retrieve hostel and room details
    DocumentSnapshot hostelSnapshot = await _firestore.collection("hostels").doc(hostelId).get();
    Map<String, dynamic> hostelData = hostelSnapshot.data() as Map<String, dynamic>;
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
      List<dynamic> occupants = roomData.containsKey("occupants") ? roomData["occupants"] : [];
      roomOccupantsCount[roomId] = occupants.length;
    }

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))
      ),
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
                  fontSize: 20, 
                  fontWeight: FontWeight.bold
                ),
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
                      onTap: isFull ? null : () => Navigator.pop(context, roomId),
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
                            width: 2
                          ),
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
                                fontWeight: FontWeight.bold
                              ),
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

  
Future<void> approveRequest(String studentId, BuildContext context) async {
  if (!context.mounted) return;  // ✅ Prevents error if widget is deactivated

  String? newRoom = await _showRoomSelectionDialog(context, hostelId);
  if (newRoom == null || newRoom.isEmpty) return;

  try {
    DocumentSnapshot studentDoc =
        await FirebaseFirestore.instance.collection("users").doc(studentId).get();

    if (!studentDoc.exists) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Student not found!")),
        );
      }
      return;
    }

    String oldRoom = studentDoc["room_no"] ?? "";

    WriteBatch batch = FirebaseFirestore.instance.batch();

    // ✅ Ensure the new room document exists before updating
    DocumentReference newRoomRef = FirebaseFirestore.instance
        .collection("hostels")
        .doc(hostelId)
        .collection("rooms")
        .doc(newRoom);

    DocumentSnapshot newRoomDoc = await newRoomRef.get();
    if (!newRoomDoc.exists) {
      batch.set(newRoomRef, {"occupants": []}, SetOptions(merge: true));
    }

    // ✅ Update student's room number
    batch.update(FirebaseFirestore.instance.collection("users").doc(studentId), {
      "room_no": newRoom,
    });

    // ✅ Remove student from old room occupants list
    if (oldRoom.isNotEmpty) {
      DocumentReference oldRoomRef = FirebaseFirestore.instance
          .collection("hostels")
          .doc(hostelId)
          .collection("rooms")
          .doc(oldRoom);

      batch.update(oldRoomRef, {
        "occupants": FieldValue.arrayRemove([studentId]),
      });
    }

    // ✅ Add student to new room occupants list
    batch.update(newRoomRef, {
      "occupants": FieldValue.arrayUnion([studentId]),
    });

    // ✅ Mark request as approved
    batch.update(FirebaseFirestore.instance.collection("room_change").doc(studentId), {
      "status": "approved",
      "approved_room": newRoom,
    });

    await batch.commit();

    // ✅ Send FCM Notification
    final fcmToken = studentDoc["FCM_tokens"] ?? [""];
    if (fcmToken.isEmpty) {
      await batch.commit();
      print("❌ No FCM tokens found for the student!");
      return;
    }

    for (var token in fcmToken) {
      await FCMService.sendNotification(
        fcmToken: token,
        title: "Room Change Approved",
        body: "Your room change request has been approved! Your new room is $newRoom.",
      );
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Room changed successfully!"), backgroundColor: Colors.green),
      );
    }
  } catch (e) {
    debugPrint("❌ Error updating room: $e");
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating room!")),
      );
    }
  }
}




void denyRequest(String studentId, BuildContext context) async {
  if (!context.mounted) return;  

  String reason = await getDenialReason(context);
  if (reason.isEmpty) return;

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
      "status": "denied",
      "reason": reason,
    });

    // ✅ Send FCM Notification
    List<String> fcmToken = studentDoc["FCM_tokens"] ?? [];

    for (var token in fcmToken) {
      print("✅ Sending FCM Notification...");
      await FCMService.sendNotification(
        fcmToken: token,
        title: "Room Change Denied",
        body: "Your room change request has been denied. Reason: $reason",
      );
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Request denied!")));
    }
  } catch (e) {
    debugPrint("❌ Error denying request: $e");
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error denying request!")));
    }
  }
}

}