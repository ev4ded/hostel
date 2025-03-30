import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Map<String, Map<String, dynamic>> cachedWardenDetails = {};
Map<String, StreamSubscription> userSubscriptions =
    {}; // Track Firestore listeners
Stream<List<Map<String, dynamic>>> listingWarden(String hostelId) {
  return FirebaseFirestore.instance
      .collection("hostels")
      .doc(hostelId)
      .collection("warden")
      .snapshots()
      //.map((snapshot) => snapshot.docs);
      .asyncMap((hostelSnapshot) async {
    List<Map<String, dynamic>> wardenList = [];

    for (var doc in hostelSnapshot.docs) {
      var wardenData = doc.data();
      String docId = doc.id;
      if (wardenData['userData'] is DocumentReference) {
        DocumentReference userRef = wardenData['userData'] as DocumentReference;

        // Fetch user data initially
        DocumentSnapshot userSnapshot = await userRef.get();
        if (userSnapshot.exists) {
          wardenData['userData'] = userSnapshot.data() as Map<String, dynamic>;
        } else {
          wardenData['userData'] = {};
        }

        // **Listen for real-time updates on userData**
        userRef.snapshots().listen((updatedSnapshot) {
          if (updatedSnapshot.exists) {
            wardenData['userData'] =
                updatedSnapshot.data() as Map<String, dynamic>;
          }
        });
      } else {
        wardenData['userData'] = wardenData['userData'] ?? {};
      }

      wardenData['docId'] = docId;
      wardenList.add(wardenData);
    }
    return wardenList;
  });
}

Stream<List<QueryDocumentSnapshot>> WardenApproval(String hostelId) {
  return FirebaseFirestore.instance
      .collection("users")
      .where('hostelId', isEqualTo: hostelId)
      .where('role', isEqualTo: 'warden')
      .where('isApproved', isEqualTo: false)
      .snapshots()
      .map((snapshot) => snapshot.docs);
}

Future<Map<String, dynamic>?> getHostelDetails(String hostelId) async {
  try {
    DocumentSnapshot hostel = await FirebaseFirestore.instance
        .collection('hostels')
        .doc(hostelId)
        .get();
    if (hostel.exists) {
      return hostel.data() as Map<String, dynamic>;
    }
  } catch (e) {
    return {'error': e};
  }
  return null;
}

Future<List<Map<String, dynamic>>?> getWardens(String hostelId) async {
  try {
    QuerySnapshot hostel = await FirebaseFirestore.instance
        .collection("users")
        .where('hostelId', isEqualTo: hostelId)
        .where('role', isEqualTo: 'warden')
        .get();
    return hostel.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      data['docId'] = doc.id; // Add document ID to the map
      return data;
    }).toList();
  } catch (e) {
    return [
      {'error': e.toString()}
    ];
  }
}

Future<String?> fetchAdminHostelId(String uid) async {
  try {
    User? user = FirebaseAuth.instance.currentUser; // Get logged-in user
    if (user == null) {
      return null;
    }
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();

    if (snapshot.exists) {
      String hostelId = snapshot["hostelId"];
      return hostelId;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

Future<void> deleteWarden(String uid, String hostelid) async {
  var docRef = FirebaseFirestore.instance.collection('users').doc(uid);
  var docSnapshot = await docRef.get();

  if (docSnapshot.exists) {
    var data = docSnapshot.data();
    if (data != null) {
      var updates = {for (var key in data.keys) key: FieldValue.delete()};
      await docRef.update(updates);
    }
  }
  await FirebaseFirestore.instance
      .collection("hostels")
      .doc(hostelid)
      .collection("warden")
      .doc(uid)
      .delete();
  FirebaseFirestore.instance.collection('users').doc(uid).set({
    'deleted': true,
  });
}
