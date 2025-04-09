import 'package:flutter/material.dart';
import 'package:minipro/Theme/appcolors.dart';

class AppThemes {
  static Color loaderColor = AppColors.buttonColor;
  static final ThemeData lightTheme = ThemeData(
    /*textSelectionTheme: TextSelectionThemeData(
      cursorColor: Colors.blueAccent,
      selectionColor: Colors.white,
      selectionHandleColor: Colors.blueAccent,
    ),*/
    brightness: Brightness.light,
    primarySwatch: Colors.teal,
    scaffoldBackgroundColor: Color.fromRGBO(225, 227, 230, 1),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFFE0F7FA),
      titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
      iconTheme: IconThemeData(color: Colors.black),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(fontSize: 18, color: Colors.black),
      bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.tealAccent,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: loaderColor, // CircularProgressIndicator color
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: loaderColor, // Text selection cursor color
      selectionColor: loaderColor.withAlpha(77), // Selected text background
      selectionHandleColor: loaderColor, // Handle color
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blueGrey,
    scaffoldBackgroundColor: Color.fromRGBO(18, 18, 18, 1),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1F2A3C),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(fontSize: 18, color: Colors.white),
      bodyMedium: TextStyle(fontSize: 16, color: Colors.white70),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: loaderColor, // CircularProgressIndicator color
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: loaderColor, // Text selection cursor color
      selectionColor: loaderColor.withAlpha(77), // Selected text background
      selectionHandleColor: loaderColor, // Handle color
    ),
  );
}
