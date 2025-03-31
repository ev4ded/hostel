import 'package:flutter/material.dart';

class AppColors {
  //dark
  static Color bg = Colors.black;
  static Color textColorDark = Colors.white;
  static Color containerColorDark = Color.fromRGBO(40, 40, 40, 1);
  static Color alretWindowColorDark = Color.fromRGBO(85, 85, 85, 1);
  static Color tileColorDark = Color.fromRGBO(78, 68, 64, 1);
  static Color detailsCDark = Color.fromRGBO(180, 195, 210, 1);
  static List<Color> wardentileDark = [Color(0xFF1E293B), Color(0xFF334155)];
  //light
  static Color bgwhite = Colors.white;
  static Color textColorLight = Colors.black;
  static Color alretWindowColorLight = Color.fromRGBO(200, 200, 200, 1);
  static Color containerColorLight = Color.fromRGBO(200, 200, 200, 1);
  static Color tileColorLight = Color.fromRGBO(210, 200, 195, 1);
  static Color detailsCLight = Color.fromRGBO(155, 165, 180, 1);
  static List<Color> wardentileGradient = [
    Color(0xFF6A85B6),
    Color.fromARGB(255, 154, 187, 244)
  ];
  //both
  static Color hintColor = Color.fromRGBO(139, 139, 139, 0.5);
  static Color borderColor = Color.fromRGBO(74, 85, 104, 1);
  static Color buttonColor = Color.fromARGB(255, 214, 163, 5);
  static Color buttonTextColor = Color.fromRGBO(18, 18, 18, 1);
  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textColorDark
        : textColorLight;
  }

  static Color getContainerColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? containerColorDark
        : containerColorLight;
  }

  static Color getTileColorLight(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? tileColorDark
        : tileColorLight;
  }

  static Color getDetailsC(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? detailsCDark
        : detailsCLight;
  }

  static Color getAlertWindowC(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? alretWindowColorDark
        : alretWindowColorLight;
  }

  static List<Color> getWardentile(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? wardentileDark // Dark mode gradient
        : wardentileGradient; // Light mode gradient
  }

  static Color getbg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? bg : bgwhite;
  }
}
