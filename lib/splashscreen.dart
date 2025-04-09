import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minipro/Admin/wardenlisting.dart';
import 'package:minipro/Theme/appcolors.dart';
import 'package:minipro/boardingpage.dart';
import 'package:minipro/deleted.dart';
import 'package:minipro/student/components/custom_route.dart';
import 'package:minipro/notverfied.dart';
import 'package:minipro/student/pages/home/vacate/vacating.dart';
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
    bool shown = roleandVerified[3];
    bool vacate = roleandVerified[4];
    print("vacating:$vacate");
    //await Future.delayed(Duration(seconds: 2));
    if (!mounted) return;
    Widget page;
    //print("deleted:$deleted");
    if (deleted) {
      page = Deleted();
    } else if (vacate) {
      page = Vacating();
    } else if (isLoggedIn && role == "admin") {
      (shown) ? (page = Wardenlisting()) : (page = Boardingpage(role: role));
    } else if (isLoggedIn && !isVerified) {
      page = Studentnotverfied();
    } else if (isLoggedIn && !shown) {
      page = Boardingpage(role: role);
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
    return Scaffold(
      backgroundColor: AppColors.getbg(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200, // Outer ring size
                    height: 200,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      color: AppColors.getTextColor(
                          context), // Adjust color as needed
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(30), // Apply border radius
                      child: Image.asset(
                        "assets/icons/logo.png",
                        width: 150, // Logo size
                        height: 130,
                        fit: BoxFit
                            .cover, // Ensures it covers the space properly
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  "Created by Group 8",
                  style: GoogleFonts.inter(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
