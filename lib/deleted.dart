import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minipro/Theme/appcolors.dart';
import 'package:minipro/authentication/fcmtoken.dart';
import 'package:minipro/authentication/loginpage.dart';
import 'package:minipro/student/components/custom_route.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Deleted extends StatelessWidget {
  const Deleted({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getTileColorLight(context),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/deleted.png"),
          Text(
            "your account have been deleted",
            style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 18),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .delete();
                await user.delete();
                FirebaseAuth.instance.signOut();
                saveLoginState(false);
                removeFCMToken(user.uid);
                Navigator.pushAndRemoveUntil(
                  context,
                  myRoute(
                    LoginPage(),
                  ),
                  (route) => false,
                );
              }
            },
            style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(AppColors.buttonColor)),
            child: Text(
              "Signout",
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  color: AppColors.buttonTextColor),
            ),
          )
        ],
      ),
    );
  }

  Future<void> saveLoginState(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }
}
