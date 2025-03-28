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
        Color.fromRGBO(95, 44, 130, 1),
        Color.fromRGBO(73, 160, 157, 1)
      ]);
    default:
      return LinearGradient(
          colors: [Colors.black, Colors.black87, Colors.black54]);
  }
}
