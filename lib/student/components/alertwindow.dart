import 'dart:async';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minipro/Theme/appcolors.dart';
import 'package:minipro/student/components/custom_route.dart';
import 'package:minipro/student/components/mysnackbar.dart';
import 'package:minipro/student/pages/profile/editprofile.dart';

void showPendingDialog(BuildContext context) {
  Color buttonColor = AppColors.buttonColor;
  Color buttonText = AppColors.buttonTextColor;
  int count = 0;
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return PopScope(
        canPop: false,
        child: Stack(
          children: [
            BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: Container(
                  color: Colors.black.withAlpha(10),
                )),
            Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              backgroundColor: AppColors.getAlertWindowC(context),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Request status",
                      style: GoogleFonts.inter(fontSize: 20),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Your request is being processed.",
                      style: GoogleFonts.inter(),
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(buttonColor),
                        ),
                        onPressed: () {
                          Navigator.popUntil(context, (route) {
                            return count++ >= 2;
                          });
                        },
                        child: Text(
                          "OK",
                          style: GoogleFonts.inter(
                              color: buttonText, fontWeight: FontWeight.w600),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

void showResolvedDialog(BuildContext context, String status) {
  Color buttonColor = AppColors.buttonColor;
  Color buttonText = AppColors.buttonTextColor;
  int count = 0;
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return PopScope(
        canPop: false,
        child: Stack(
          children: [
            BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: Container(
                  color: Colors.black.withAlpha(10),
                )),
            Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              backgroundColor: AppColors.getAlertWindowC(context),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Request status",
                      style: GoogleFonts.inter(fontSize: 20),
                    ),
                    SizedBox(height: 20),
                    Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          softWrap: true,
                          "Your latest request has been $status.",
                          style: GoogleFonts.inter(),
                        )),
                    SizedBox(height: 5),
                    Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.popUntil(context, (route) {
                                  return count++ >= 2;
                                });
                              },
                              child: Text(
                                "cancel",
                                style: GoogleFonts.inter(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStatePropertyAll(buttonColor),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  "Apply again",
                                  style: GoogleFonts.inter(
                                      color: buttonText,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ))
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> showEmailVerifictionDialog(BuildContext context) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  await user.sendEmailVerification();
  void showSnackBar(String message, {bool isError = false}) {
    Mysnackbar.show(context, message, isError: isError);
  }

  Completer<void> completer = Completer<void>(); // ✅ Keeps dialog open
  Timer? timer;
  if (!context.mounted) return;
  showDialog(
    context: context,
    barrierDismissible: false, // ✅ Prevents closing until verified
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        title: Text("Verify your Email"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text("Waiting for email to be verified..."),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await user.sendEmailVerification();
              showSnackBar("Email verified successfully");
            },
            child: Text("Resend Email"),
          ),
        ],
      );
    },
  );

  /// **🔹 Keep checking if the email is verified**
  timer = Timer.periodic(Duration(seconds: 3), (timer) async {
    await FirebaseAuth.instance.currentUser?.reload(); // Refresh user data
    User? updatedUser = FirebaseAuth.instance.currentUser;
    print("Updated emailVerified: ${updatedUser?.emailVerified}");
    if (updatedUser != null && updatedUser.emailVerified) {
      timer.cancel(); // ✅ Stop checking
      if (!context.mounted) return;
      Navigator.of(context).pop(); // ✅ Close dialog

      completer.complete(); // ✅ Mark function as complete
    }
  });

  return completer.future; // ✅ Ensures function waits until verification
}

Future<void> passwordResetDialog(BuildContext context) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  await user.sendEmailVerification();
  void showSnackBar(String message, {bool isError = false}) {
    Mysnackbar.show(context, message, isError: isError);
  }

  if (!context.mounted) return;
  showDialog(
    context: context,
    barrierDismissible: false, // ✅ Prevents closing until verified
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        title: Text("Verify your Email"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text("Waiting for email to be verified..."),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await user.sendEmailVerification();
              showSnackBar("Email verified successfully");
            },
            child: Text("Resend Email"),
          ),
        ],
      );
    },
  );
}

void editProfile(BuildContext context) {
  Color buttonColor = AppColors.buttonColor;
  Color buttonText = AppColors.buttonTextColor;
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return PopScope(
        canPop: false,
        child: Stack(
          children: [
            BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: Container(
                  color: Colors.black.withAlpha(10),
                )),
            Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              backgroundColor: AppColors.getAlertWindowC(context),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Please edit the profile first",
                      style: GoogleFonts.inter(fontSize: 18),
                    ),
                    SizedBox(height: 20),
                    Text(
                      softWrap: true,
                      "After editing the pop up still there please try relaunching the app",
                      style: GoogleFonts.inter(fontSize: 14),
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(buttonColor),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            myRoute(Editprofile()),
                          );
                        },
                        child: Text(
                          "edit",
                          style: GoogleFonts.inter(
                              color: buttonText, fontWeight: FontWeight.w600),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
