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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // Rounded corners
      ),
      title: Text(
        "Denial Reason",
        style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Please enter a reason for denying the request:",
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[700]),
          ),
          SizedBox(height: 12),
          TextField(
            controller: reasonController,
            decoration: InputDecoration(
              hintText: "Enter reason...",
              hintStyle: GoogleFonts.inter(color: Colors.grey[500]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12), // Rounded input field
              ),
              contentPadding: EdgeInsets.all(12),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, ""),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[700], // Softer cancel button color
          ),
          child: Text("Cancel", style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
        ),
        ElevatedButton(
          onPressed: () {
            String reason = reasonController.text.trim();
            if (reason.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Please enter a reason", style: GoogleFonts.inter()),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.redAccent,
                ),
              );
              return;
            }
            Navigator.pop(context, reason);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent, // Highlight denial button
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text("Submit", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  },
) ?? "";
}

Future<void> removeStudent(String docId, String hostelId) async {
  var docRef = FirebaseFirestore.instance.collection('users').doc(docId);
  var docSnapshot = await docRef.get();

  if (!docSnapshot.exists) return;

  var data = docSnapshot.data();
  if (data == null) return;

  String? roomNo = data['room_no']; // Get student's room number

  // Remove student from the room occupants
  if (roomNo != null && roomNo.isNotEmpty) {
    var roomRef = FirebaseFirestore.instance
        .collection('hostels')
        .doc(hostelId)
        .collection('rooms')
        .doc(roomNo);

    await roomRef.update({
      'occupants': FieldValue.arrayRemove([docId]) // Remove student ID from room
    });
  
  await FirebaseFirestore.instance.collection('users').doc(docId).set({
    'deleted': true,
    'profileUpdated':false,
  }, SetOptions(merge: true)); // Preserve other fields

  debugPrint("✅ Student $docId removed successfully.");
}
}

Future<void> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmText,
  required Color confirmColor,
  required VoidCallback onConfirm,
 
}) async {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm(); // Call the provided function when confirmed
          },
          style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
          child: Text(confirmText.toUpperCase()),
        ),
      ],
    ),
  );
}


