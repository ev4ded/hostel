//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minipro/warden/wardenQueries/queries.dart';


class RoomChange extends StatefulWidget {
  const RoomChange({super.key});

  @override
  _RoomChangeState createState() => _RoomChangeState();
}

class _RoomChangeState extends State<RoomChange> {
  String? hostelId;
  String? wardenRoomNo;

  @override
  void initState() {
    super.initState();
   someFunction();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Room Change Requests", style: GoogleFonts.inter())),
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
              future: _firestore.collection("users").doc(studentId).get(),
              builder: (context, userSnapshot) {

                 if (userSnapshot.connectionState == ConnectionState.waiting) {
                            return SizedBox(); // Prevent unnecessary UI updates while loading
                     }
                

                var userData = userSnapshot.data!.data() as Map<String, dynamic>;
                if (userData.isEmpty || userData["hostelId"] != hostelId) {
                      return SizedBox(); // Skip if hostel ID does not match
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
  
 void approveRequest(String studentId, BuildContext context) async {
  String? newRoom = await selectRoom(context);
  if (newRoom == null || newRoom.isEmpty) return;

  try {
    // Fetch student details from users collection
    DocumentSnapshot studentDoc = await _firestore.collection("users").doc(studentId).get();
    
    if (!studentDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Student not found!")));
      return;
    }

    // Update room_change collection
    await _firestore.collection("room_change").doc(studentId).update({
      "status": "approved",
      "approved_room": newRoom,
    });

    // Update users collection (assign new room)
    await _firestore.collection("users").doc(studentId).update({
      "room_no": newRoom,
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Room changed successfully!")));
  } catch (e) {
    debugPrint("❌ Error updating room: $e");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error updating room!")));
  }
}


  void denyRequest(String studentId, BuildContext context) async {
    String reason = await getDenialReason(context);
    if (reason.isEmpty) return;

    await _firestore.collection("room_change").doc(studentId).update({
      "status": "denied",
      "reason": reason,
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Request denied!")));
  }
}