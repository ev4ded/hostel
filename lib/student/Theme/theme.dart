import 'package:flutter/material.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    /*textSelectionTheme: TextSelectionThemeData(
      cursorColor: Colors.blueAccent,
      selectionColor: Colors.white,
      selectionHandleColor: Colors.blueAccent,
    ),*/
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Color.fromRGBO(255, 253, 208, 0.8),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(fontSize: 18, color: Colors.black),
      bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blueGrey,
    scaffoldBackgroundColor: Color.fromRGBO(18, 18, 18, 1),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blueGrey[900],
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
  );
}
