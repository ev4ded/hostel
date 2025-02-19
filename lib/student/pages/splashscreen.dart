import 'package:flutter/material.dart';
import 'package:minipro/student/components/custom_route.dart';
import 'package:minipro/student/pages/navigator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../authentication/loginpage.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
    //await Future.delayed(Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      myRoute(isLoggedIn ? MainNavigator() : LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
