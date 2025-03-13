import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

 Future<String?> fetchHostelId() async {
  try {
    User? user = FirebaseAuth.instance.currentUser; // Get logged-in user
    if (user == null) {
      debugPrint("⚠️ No user is logged in.");
      return null;
    }
    debugPrint("✅ Logged-in user: ${user.email}");

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: user.email) // Fetch warden by email
        .where("role", isEqualTo: "warden")
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      String hostelId = snapshot.docs.first["hostelId"];
      debugPrint("🏠 Hostel ID: $hostelId");
      return hostelId;
    } else {
      debugPrint("⚠️ No hostel found for this warden.");
      return null;
    }
  } catch (e) {
    debugPrint("❌ Error fetching hostel ID: $e");
    return null;
  }
}


Future<String> getDenialReason(BuildContext context) async {
  TextEditingController reasonController = TextEditingController();

  return await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Deny Request", style: GoogleFonts.inter()),
            content: TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: "Enter reason for denial",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, ""),
                child: Text("Cancel", style: GoogleFonts.inter()),
              ),
              ElevatedButton(
                onPressed: () {
                  String reason = reasonController.text.trim();
                  if (reason.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please enter a reason")),
                    );
                    return;
                  }
                  Navigator.pop(context, reason);
                },
                child: Text("Submit", style: GoogleFonts.inter()),
              ),
            ],
          );
        },
      ) ??
      "";
}
/*Future<String?> selectRoom(BuildContext context, String hostelId) async {
  String? selectedRoom;
  List<String> availableRooms = [];

  try {
    QuerySnapshot roomSnapshot = await FirebaseFirestore.instance
        .collection("rooms")
        .where("hostel_id", isEqualTo: hostelId)
        .where("is_occupied", isEqualTo: false)
        .get();

    availableRooms = roomSnapshot.docs.map((doc) => doc["room_no"] as String).toList();

    if (availableRooms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No available rooms in this hostel.")),
      );
      return null;
    }
  } catch (e) {
    debugPrint("❌ Error fetching available rooms: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error fetching rooms.")),
    );
    return null;
  }

  return await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Select a Room", style: GoogleFonts.inter()),
        content: DropdownButtonFormField<String>(
          value: selectedRoom,
          items: availableRooms.map((room) {
            return DropdownMenuItem(
              value: room,
              child: Text("Room $room"),
            );
          }).toList(),
          onChanged: (value) {
            selectedRoom = value;
          },
          decoration: InputDecoration(
            labelText: "Available Rooms",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text("Cancel", style: GoogleFonts.inter()),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedRoom == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please select a room")),
                );
                return;
              }
              Navigator.pop(context, selectedRoom);
            },
            child: Text("Confirm", style: GoogleFonts.inter()),
          ),
        ],
      );
    },
  );
}*/
Future<String?> selectRoom(BuildContext context) async {
  TextEditingController roomController = TextEditingController();

  return await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Enter New Room Number", style: GoogleFonts.inter()),
        content: TextField(
          controller: roomController,
          decoration: InputDecoration(
            hintText: "Enter room number",
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text("Cancel", style: GoogleFonts.inter()),
          ),
          ElevatedButton(
            onPressed: () {
              String newRoom = roomController.text.trim();
              if (newRoom.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please enter a room number")),
                );
                return;
              }
              Navigator.pop(context, newRoom);
            },
            child: Text("Confirm", style: GoogleFonts.inter()),
          ),
        ],
      );
    },
  );
}
