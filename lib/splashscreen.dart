import 'package:flutter/material.dart';
import 'package:minipro/Admin/wardenlisting.dart';
import 'package:minipro/deleted.dart';
import 'package:minipro/student/components/custom_route.dart';
import 'package:minipro/notverfied.dart';
import 'package:minipro/student/pages/navigator.dart';
import 'package:minipro/warden/pages/navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:minipro/firebase/firestore_services.dart';

import 'authentication/loginpage.dart';

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
    List roleandVerified = await FirestoreServices().getUserRoleandVerified();
    String role = roleandVerified[0];
    bool isVerified = roleandVerified[1];
    bool deleted = roleandVerified[2];
    //await Future.delayed(Duration(seconds: 2));
    print("$isVerified");
    if (!mounted) return;
    Widget page;
    //print("deleted:$deleted");
    if (deleted) {
      page = Deleted();
    } else if (isLoggedIn && role == "admin") {
      page = Wardenlisting();
    } else if (isLoggedIn && !isVerified) {
      page = Studentnotverfied();
    } else if (isLoggedIn && role == "warden") {
      page = MyNavigation();
    } else if (isLoggedIn && role == "student") {
      page = MainNavigator();
    } else {
      page = LoginPage();
    }
    Navigator.pushAndRemoveUntil(
      context,
      myRoute(page),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
