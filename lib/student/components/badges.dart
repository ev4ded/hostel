import 'package:flutter/material.dart';

LinearGradient getbadgesColor(String badge) {
  switch (badge) {
    case 'Newbie':
      return LinearGradient(colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)]);
    case 'Resident':
      return LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]);
    case 'Hostel Elite':
      return LinearGradient(colors: [Color(0xFFFF6D00), Color(0xFFFFD600)]);
    case 'Student':
      return LinearGradient(colors: [
        Color.fromRGBO(255, 88, 88, 1),
        Color.fromRGBO(255, 200, 200, 1)
      ]);
    default:
      return LinearGradient(
          colors: [Colors.black, Colors.black87, Colors.black54]);
  }
}
