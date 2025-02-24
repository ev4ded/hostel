import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<QueryDocumentSnapshot>> getStudentMaintenance(String uid) async {
  try {
    QuerySnapshot maintenance = await FirebaseFirestore.instance
        .collection('maintenance_request')
        .where('student_id',
            isEqualTo: uid) // Replace with actual student ID  user.uid
        .orderBy('created_at', descending: true)
        .get();
    return maintenance.docs;
  } catch (e) {
    print("error:$e");
    return [];
  }
}

Future<List<QueryDocumentSnapshot>> getStudentComplaint(String uid) async {
  try {
    QuerySnapshot complaints = await FirebaseFirestore.instance
        .collection('complaints')
        .where('student_id',
            isEqualTo: uid) // Replace with actual student ID  user.uid
        .orderBy('created_at', descending: true)
        .get();
    return complaints.docs;
  } catch (e) {
    print("error:$e");
    return [];
  }
}

Future<Map<String, List<String>>> getMenu(String hostelId) async {
  try {
    QuerySnapshot maintenance = await FirebaseFirestore.instance
        .collection('mess_menu')
        .where('hostelId',
            isEqualTo: hostelId) // Replace with actual student ID  user.uid
        .get();
    if (maintenance.docs.isNotEmpty) {
      var doc = maintenance.docs.first;
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return {
        "breakfast": List<String>.from(data["breakfast"] ?? []),
        "lunch": List<String>.from(data["lunch"] ?? []),
        "dinner": List<String>.from(data["dinner"] ?? []),
        "snacks": List<String>.from(data["snacks"] ?? []),
      };
    } else {
      print("No menu found");
      return {};
    }
  } catch (e) {
    print("error:$e");
    return {};
  }
}
