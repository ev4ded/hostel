import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

LinearGradient getbadgesColor(String badge) {
  switch (badge) {
    //basic
    case 'Newbie':
      return LinearGradient(colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)]);
    case 'Resident':
      return LinearGradient(
        colors: [
          Color(0xFFFF4500), // Orange-Red
          Color(0xFFFFD700), // Bright Gold
          Color(0xFF8B0000), // Deep Red
        ],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      );
    case 'Hostel Elite':
      return LinearGradient(
        colors: [
          Color(0xFF00FFFF), // Cyan
          Color(0xFF007FFF), // Electric Blue
          Color(0xFF8A2BE2), // Deep Purple
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case 'Student':
      return LinearGradient(colors: [
        Color.fromRGBO(255, 88, 88, 1),
        Color.fromRGBO(255, 200, 200, 1)
      ]);
    //the best
    case 'The Best':
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF2C3E50), // Deep blue
          Color(0xFF6C757D), // Neutral grey smoke
        ],
      );
    //special
    case 'Bug Buster':
      return LinearGradient(
        colors: [
          Color(0xFF00FF00), // Neon Green (Debugging Vibes)
          Color(0xFF00CED1), // Dark Cyan (Techy Look)
          Color(0xFF1E90FF), // Dodger Blue (Victory Over Bugs)
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    //usual
    case "Nightmare":
      return LinearGradient(
        colors: [
          Color(
              0xFFFFD700), // Gold (Because they think they deserve VIP treatment)
          Color(0xFFFFA500), // Orange (Warden is slightly annoyed)
          Color(0xFF800080), // Deep Purple (The tension is real)
        ],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      );
    case 'Not Available': //The Vanishing Act
      return LinearGradient(
        colors: [
          Color(0xFFB0C4DE), // Light Steel Blue (Barely Visible)
          Color(0xFF708090), // Slate Gray (Already Fading)
          Color(0xFF2F4F4F), // Black (Gone... Forever?)
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case 'Fix It': //Fix It or I Riot
      return LinearGradient(
        colors: [
          Color(0xFFFF0000), // Bright Red (Pure Rage)
          Color(0xFFFF4500), // Orange-Red (Annoyance Level Rising)
          Color(0xFFFFD700), // Gold (Satisfaction When Fixed)
        ],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      );
    default:
      return LinearGradient(
          colors: [Colors.black, Colors.black87, Colors.black54]);
  }
}

String getBadges(Map<String, dynamic> scores, String type) {
  print(scores);

  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return "null";

  String? badge;
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  if (scores['score'] == 5) {
    badge = 'Resident';
  } else if (scores['score'] == 15) {
    badge = 'Hostel Elite';
  } else if (type == 'maintenance' && scores['maintenance'] == 4) {
    badge = 'Fix It';
  } else if (type == 'complaint' && scores['complaint'] == 4) {
    badge = 'Nightmare';
  } else if (type == 'leave' && scores['leave'] == 4) {
    badge = 'Not Available';
  }

  if (badge != null) {
    users.doc(user.uid).update({
      'badges': FieldValue.arrayUnion([badge])
    });
    return badge;
  }

  return "";
}

Future<Map<String, dynamic>?> getScore() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;
  DocumentSnapshot scores =
      await FirebaseFirestore.instance.collection('points').doc(user.uid).get();
  if (!scores.exists) return null;
  return scores.data() as Map<String, dynamic>;
}
