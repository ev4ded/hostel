import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void updateFCMToken(String uid) async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // 🔹 Get the initial token
  String? token = await messaging.getToken();
  if (token != null) {
    await FirebaseFirestore.instance.collection("users").doc(uid).update({
      'FCM_tokens': FieldValue.arrayUnion(
          [token]), // Add to array for multi-device support
    });
  }

  // 🔹 Listen for token refresh
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    await FirebaseFirestore.instance.collection("users").doc(uid).update({
      'FCM_tokens': FieldValue.arrayUnion([newToken]), // Add new token
    });
  }).onError((err) {
    print("FCM Token Refresh Error: $err");
  });
}

void removeFCMToken(String uid) async {
  String? token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    await FirebaseFirestore.instance.collection("users").doc(uid).update({
      'FCM_tokens': FieldValue.arrayRemove([token]), // Remove token on logout
    });
  }
}
