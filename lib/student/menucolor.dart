import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Menucolor extends ChangeNotifier {
  int _option = 0;
  static final Map<int, Map<String, Color>> themes = {
    0: {
      "iconC": Color.fromRGBO(255, 189, 109, 1),
      "menuC": Color.fromRGBO(213, 185, 145, 1),
      "innerC": Color.fromRGBO(224, 199, 174, 1),
      "text": Color.fromRGBO(120, 47, 32, 1),
    },
    1: {
      "iconC": Color.fromRGBO(255, 189, 109, 1),
      "menuC": Color.fromRGBO(114, 47, 55, 1),
      "innerC": Color.fromRGBO(239, 223, 187, 1),
      "text": Color.fromRGBO(70, 30, 35, 1),
    },
    2: {
      // Blue-ish theme
      "iconC": Color.fromRGBO(200, 200, 255, 1),
      "menuC": Color.fromRGBO(60, 90, 180, 1),
      "innerC": Color.fromRGBO(180, 200, 230, 1),
      "text": Color.fromRGBO(255, 255, 255, 1),
    },
  };
  Menucolor() {
    _loadTheme();
  }

  int get selectedTheme => _option;
  Map<String, Color> get currentTheme => themes[_option]!;

  Future<void> setTheme(int themeIndex) async {
    _option = themeIndex;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("menuCardColor", themeIndex); // Save to storage
  }

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _option = prefs.getInt("menuCardColor") ?? 0; // Load from storage
    notifyListeners();
  }

  Future<void> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _option = prefs.getInt("menuCardColor") ?? 0;
    notifyListeners();
  }
}
