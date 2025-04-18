import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FirestoreServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get userDocument {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    return _firestore.collection("users").doc(uid);
  }

  Future<void> getUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      DocumentSnapshot userDoc = await _firestore
          .collection("users")
          .doc(user.uid)
          .get(const GetOptions(source: Source.server));
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("userData", jsonEncode(userData));
      }
    } catch (e) {
      print("getUserData: $e");
    }
  }

  Future<Map<String, dynamic>?> getCachedUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userData = prefs.getString("userData");
      if (userData != null) {
        return jsonDecode(userData) as Map<String, dynamic>;
      }
    } catch (e) {
      print("getCachedUserData: $e");
    }
    return null;
  }

  Future<void> signOut() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove("userData");
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print("signOut: $e");
    }
  }

  Future<List> getUserRoleandVerified() async {
    await getUserData();
    Map<String, dynamic>? user = await getCachedUserData();
    String role = "";
    bool isVerified = false;
    bool deleted = false;
    bool shown = false;
    bool vacate = false;
    try {
      if (user != null) {
        role = user["role"] ?? "";
        isVerified = user["isApproved"] ?? false;
        deleted = user["deleted"] ?? false;
        shown = user["boardingPage"] ?? false;
        vacate = user['vacating'] ?? false;
      } else {
        await getUserData();
        user = await getCachedUserData();
        role = user!["role"] ?? "";
        isVerified = user["isApproved"] ?? false;
        deleted = user["deleted"] ?? false;
        shown = user["boardingPage"] ?? false;
        print("isvacating:$user['vacating']");
        vacate = user['vacating'] ?? false;
      }
    } catch (e) {
      debugPrint("error :$e");
    }
    return [role, isVerified, deleted, shown, vacate];
  }

  Future<Map<String, dynamic>?> getUserDetails() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      DocumentSnapshot userDoc =
          await _firestore.collection("users").doc(user.uid).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      } else {
        print("No user found");
      }
    } catch (e) {
      print("getUserData: $e");
    }
    return null;
  }

  Future<List> getRoomChangeStatus() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot doc =
            await _firestore.collection("room_change").doc(user.uid).get();
        if (doc.exists) {
          if (doc["status"] == "approved") {
            return [doc["status"], doc["room_no"]];
          } else if (doc["status"] == "denied") {
            return [doc["status"], doc["reason"]];
          } else {
            return [doc["status"]];
          }
        }
      }
      return [""];
    } catch (e) {
      debugPrint("error:${e.toString()}");
    }
    return [""];
  }

  Future<Map<String, dynamic>?> getHostelDetails(String hostelId) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      DocumentSnapshot userDoc =
          await _firestore.collection("hostels").doc(hostelId).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      } else {
        print("No user found");
      }
    } catch (e) {
      print("getUserData: $e");
    }
    return null;
  }
}

void listenToUserUpdates() {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print("null");
    return;
  }
  FirebaseFirestore.instance
      .collection('users') // Change to your collection
      .doc(user.uid) // Replace with the actual user ID
      .snapshots()
      .listen((snapshot) async {
    if (snapshot.exists) {
      Map<String, dynamic> updatedValue = snapshot.data() as Map<String,
          dynamic>; // Replace 'key' with the field name in Firestore

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userData', jsonEncode(updatedValue));
      print('SharedPreferences updated');
    }
  });
}
