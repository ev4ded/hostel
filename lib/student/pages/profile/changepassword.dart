import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minipro/Theme/appcolors.dart';
import 'package:minipro/authentication/forgotpassword.dart';
import 'package:minipro/student/components/mysnackbar.dart';
import 'package:minipro/student/components/mytextfield.dart';

class Changepassword extends StatefulWidget {
  const Changepassword({super.key});

  @override
  State<Changepassword> createState() => _ChangepasswordState();
}

class _ChangepasswordState extends State<Changepassword> {
  final double borderWidth = 1;
  final double borderRadius = 15;
  final Color borderColor = AppColors.borderColor;
  Color hintColor = AppColors.hintColor;
  Color buttonColor = AppColors.buttonColor;
  Color buttonTextColor = AppColors.buttonTextColor;
  final emailController = TextEditingController();
  final currentController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Color textColor = AppColors.getTextColor(context);
    Color bgColor = AppColors.getContainerColor(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              Text(
                "Change Password",
                style: GoogleFonts.inter(fontSize: 20),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                "our password must be at least 8 characters long, with a mix of uppercase, lowercase, numbers, and special characters (e.g., @, #, \$). Avoid common words and reuse.",
                softWrap: true,
                style: GoogleFonts.inter(fontSize: 15),
              ),
              SizedBox(
                height: 20,
              ),
              Mytextfield(
                bgColor: bgColor,
                borderColor: borderColor,
                borderRadius: borderRadius,
                borderWidth: borderWidth,
                hinttext: "current password",
                textColor: textColor,
                hintColor: hintColor,
                isHidden: true,
                controller: currentController,
              ),
              SizedBox(
                height: 15,
              ),
              Mytextfield(
                bgColor: bgColor,
                borderColor: borderColor,
                borderRadius: borderRadius,
                borderWidth: borderWidth,
                hinttext: "New password",
                textColor: textColor,
                hintColor: hintColor,
                isHidden: true,
                controller: newController,
              ),
              SizedBox(
                height: 15,
              ),
              Mytextfield(
                bgColor: bgColor,
                borderColor: borderColor,
                borderRadius: borderRadius,
                borderWidth: borderWidth,
                hinttext: "Confirm new password",
                textColor: textColor,
                hintColor: hintColor,
                isHidden: true,
                controller: confirmController,
              ),
              SizedBox(
                height: 10,
              ),
              TextButton(
                onPressed: () {
                  Forgotpassword();
                },
                child: Text(
                  "forgot password?",
                  style: GoogleFonts.inter(color: Colors.blueAccent),
                ),
              ),
              SizedBox(
                height: 10,
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
      ),
    );
  }

  Future<void> reset() async {
    if (currentController.text.isEmpty ||
        newController.text.isEmpty ||
        confirmController.text.isEmpty) {
      showSnackBar("Please enter your email", isError: true);
      return;
    }
    User? user = FirebaseAuth.instance.currentUser;
    try {
      if (user == null) return;
      //if(currentController.text!=user.)
      await user.updatePassword(newController.text);
      showSnackBar("Password updated successfully");
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
