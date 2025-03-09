import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minipro/Theme/appcolors.dart';
import 'package:minipro/authentication/fcmtoken.dart';
import 'package:minipro/authentication/loginpage.dart';
import 'package:minipro/student/components/customProfilepopUp.dart';
import 'package:minipro/student/components/custom_route.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Studentnotverfied extends StatelessWidget {
  const Studentnotverfied({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(
            image: AssetImage("assets/images/being_verified.png"),
          ),
          Text(
            "Heyy,Your account is not verified yet",
            style: GoogleFonts.poppins(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "Please contact the warden",
            style: GoogleFonts.poppins(
                color: Colors.black, fontSize: 16, fontWeight: FontWeight.w400),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.heavyImpact();
              customPopup(
                context,
                "Are you sure to sign out?",
                () {
                  FirebaseAuth.instance.signOut();
                  saveLoginState(false);
                  User? userid = FirebaseAuth.instance.currentUser;
                  removeFCMToken(userid!.uid);
                  Navigator.pushAndRemoveUntil(
                    context,
                    myRoute(
                      LoginPage(),
                    ),
                    (route) => false,
                  );
                },
              );
            },
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(AppColors.buttonColor),
            ),
            child: Text("Sign out",
                style: GoogleFonts.poppins(
                    color: AppColors.buttonTextColor,
                    fontWeight: FontWeight.w600)),
          )
        ],
      )),
    );
  }

  Future<void> saveLoginState(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }
}
