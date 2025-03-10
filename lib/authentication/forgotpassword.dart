import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minipro/Theme/appcolors.dart';
import 'package:minipro/student/components/emailtextfield.dart';
import 'package:minipro/student/components/mysnackbar.dart';

class Forgotpassword extends StatefulWidget {
  const Forgotpassword({super.key});

  @override
  State<Forgotpassword> createState() => _ForgotpasswordState();
}

class _ForgotpasswordState extends State<Forgotpassword> {
  final emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            Text(
              "enter your email address",
              style: GoogleFonts.poppins(),
            ),
            SizedBox(
              height: 10,
            ),
            Emailtextfield(
              bgColor: AppColors.getAlertWindowC(context),
              borderColor: AppColors.borderColor,
              borderRadius: 15,
              borderWidth: 1,
              controller: emailController,
              hinttext: "enter your email",
              textColor: AppColors.getTextColor(context),
              hintColor: AppColors.hintColor,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "You will receive a password reset request on this account.",
              style: GoogleFonts.poppins(),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                reset();
              },
              style: ButtonStyle(
                  backgroundColor:
                      WidgetStatePropertyAll(AppColors.buttonColor)),
              child: Text(
                "Reset password",
                style: GoogleFonts.poppins(color: AppColors.buttonTextColor),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> reset() async {
    if (emailController.text.isEmpty) {
      showSnackBar("Please enter your email", isError: true);
      return;
    }
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());
      showSnackBar("Password reset link sent to your email.");
      Future.delayed(Duration(seconds: 1), () {
        if (context.mounted) {
          Navigator.pop(context);
        }
      });
    } catch (e) {
      print("error:${e.toString()}");
    }
  }

  void showSnackBar(String message, {bool isError = false}) {
    Mysnackbar.show(context, message, isError: isError);
  }
}
