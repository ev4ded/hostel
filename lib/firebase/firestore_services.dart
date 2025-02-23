import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FirestoreServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> getUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      DocumentSnapshot userDoc =
          await _firestore.collection("users").doc(user.uid).get();
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

  Future<String> getUserRole() async {
    Map<String, dynamic>? user = await getCachedUserData();
    String role = "";
    try {
      if (user != null) {
        role = user["role"];
      } else {
        await getUserData();
        user = await getCachedUserData();
        role = user!["role"];
      }
    } catch (e) {
      print("error :$e");
    }
    return role;
  }
}
