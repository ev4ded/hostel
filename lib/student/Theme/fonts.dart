import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFonts {
  static const String fontFamily = 'CustomFont';

  static TextStyle heading = GoogleFonts.raleway(
      textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold));

  static TextStyle subheading = GoogleFonts.nunito(
      textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold));

  static TextStyle body = GoogleFonts.nunito(
      textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold));

  static TextStyle caption = GoogleFonts.nunito(
      textStyle: TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey));
  static TextStyle greeting = GoogleFonts.nunito(
      textStyle: TextStyle(fontSize: 100, fontWeight: FontWeight.bold));
}
