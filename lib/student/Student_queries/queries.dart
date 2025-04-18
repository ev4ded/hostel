import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Stream<List<QueryDocumentSnapshot>> getStudentMaintenance(String uid) {
  return FirebaseFirestore.instance
      .collection("maintenance_request")
      .where('student_id',
          isEqualTo: uid) // Replace with actual student ID  user.uid
      .orderBy('created_at', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs);
}

Stream<List<QueryDocumentSnapshot>> getStudentComplaint(String uid) {
  return FirebaseFirestore.instance
      .collection("complaints")
      .where('student_id',
          isEqualTo: uid) // Replace with actual student ID  user.uid
      .orderBy('created_at', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs);
}

Future<Map<String, String>> getMenu(String hostelId) async {
  try {
    DocumentSnapshot menu = await FirebaseFirestore.instance
        .collection('mess_menu')
        .doc(hostelId) // Replace with actual student ID  user.uid
        .get();
    if (menu.exists) {
      Map<String, dynamic> data = menu.data() as Map<String, dynamic>;
      return {
        "breakfast": data["breakfast"] ?? "",
        "lunch": data["lunch"] ?? "",
        "dinner": data["dinner"] ?? "",
        "snacks": data["snacks"] ?? "",
      };
    } else {
      return {};
    }
  } catch (e) {
    debugPrint("error:$e");
    return {};
  }
}

Future<String?> getLatestLeaveRequest() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot doc = await FirebaseFirestore.instance
          .collection("leave_application")
          .where("student_id", isEqualTo: user.uid)
          .orderBy("created_at", descending: true)
          .limit(1)
          .get();
      if (doc.docs.isNotEmpty) {
        var latestLeave = doc.docs.first;
        Map<String, dynamic> data = latestLeave.data() as Map<String, dynamic>;
        return data["status"] as String;
      }
    }
    return null;
  } catch (e) {
    return null;
  }
}

Future<List<Map<String, String>>?> getRoomates(
    String hostelId, String roomno) async {
  List<Map<String, String>> mates = [];
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("hostels")
          .doc(hostelId)
          .collection('rooms')
          .doc(roomno)
          .get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List occupants = data['occupants'] ?? [];
        //print(occupants);
        for (var occupant in occupants) {
          if (occupant != user.uid) {
            DocumentSnapshot userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(occupant)
                .get();
            if (userDoc.exists) {
              String name = userDoc['username'] ?? 'Unknown';
              String badgeName = userDoc['badgeName'] ?? 'No Badge';
              //print("name:${userDoc['username']}");
              mates.add({'name': name, 'badgeName': badgeName});
              //print(name);
            }
          }
        }
        //print("mates:$mates");
      }
      return mates;
    }
    return null;
  } catch (e) {
    debugPrint("Error fetching roommates: $e");
    return null;
  }
}

Future<int> countDays(int month) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print("null");
    return 0;
  }
  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('attendance')
      .where('month', isEqualTo: month)
      .get();
  return snapshot.docs.length;
}
