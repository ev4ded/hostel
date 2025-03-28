import 'package:flutter/material.dart';

class AppColors {
  //dark
  static Color textColorDark = Colors.white;
  static Color containerColorDark = Color.fromRGBO(40, 40, 40, 1);
  static Color alretWindowColorDark = Color.fromRGBO(85, 85, 85, 1);
  static Color tileColorDark = Color.fromRGBO(78, 68, 64, 1);
  static Color detailsCDark = Color.fromRGBO(180, 195, 210, 1);
  static Color wardentileDark = const Color.fromARGB(255, 74, 72, 72);
  //light
  static Color textColorLight = Colors.black;
  static Color alretWindowColorLight = Color.fromRGBO(200, 200, 200, 1);
  static Color containerColorLight = Color.fromRGBO(200, 200, 200, 1);
  static Color tileColorLight = Color.fromRGBO(210, 200, 195, 1);
  static Color detailsCLight = Color.fromRGBO(155, 165, 180, 1);
  static Color wardentileLight = Color.fromRGBO(112, 124, 232, 1);
  //both
  static Color hintColor = Color.fromRGBO(139, 139, 139, 0.5);
  static Color borderColor = Color.fromRGBO(74, 85, 104, 1);
  static Color buttonColor = Color.fromRGBO(255, 189, 109, 1);
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
  static Color getWardentile(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ?  wardentileDark
        :  wardentileLight;
  }
}
