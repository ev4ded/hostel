import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:minipro/Theme/appcolors.dart';
import 'package:minipro/student/Student_queries/queries.dart';
import 'package:minipro/student/components/alertWindow.dart';
import 'package:minipro/student/components/badges.dart';
import 'package:minipro/student/components/mydate.dart';
import 'package:minipro/student/components/mydropdownmenu.dart';
import 'package:minipro/student/components/mysnackbar.dart';
import 'package:minipro/student/components/mytextfield.dart';

class Leaveapplication extends StatefulWidget {
  const Leaveapplication({super.key});

  @override
  State<Leaveapplication> createState() => _LeaveapplicationState();
}

class _LeaveapplicationState extends State<Leaveapplication> {
  final double borderWidth = 1;
  final double borderRadius = 15;
  final Color borderColor = AppColors.borderColor;
  Color hintColor = AppColors.hintColor;
  Color buttonColor = AppColors.buttonColor;
  Color buttonTextColor = AppColors.buttonTextColor;
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _reasonController = TextEditingController();
  String status = "";
  bool isloading = true;
  String type = "";
  Map<String, dynamic>? scores;
  @override
  void initState() {
    super.initState();
    leaveStatus();
  }

  Future<void> leaveStatus() async {
    try {
      isloading = true; // Start loading state
      String? localstatus = await getLatestLeaveRequest();

      if (localstatus != null) {
        setState(() {
          status = localstatus;
          isloading = false;
        });
        if (status == "pending" && mounted) {
          showPendingDialog(context); // Show dialog automatically
        } else if ((status == "approved" || status == "denied") && mounted) {
          showResolvedDialog(context, status); // Show dialog automatically
        }
      } else {
        _showSnackBar("First leave application...");
      }
      scores = await getScore();
    } catch (e) {
      _showSnackBar("Error fetching leave status: ${e.toString()}");
    } finally {
      setState(() {
        isloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = AppColors.getContainerColor(context);
    Color textColor = AppColors.getTextColor(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(LucideIcons.chevronLeft)),
        title: Text(
          "Leave Application",
          style: GoogleFonts.inter(),
        ),
      ),
      body: (isloading)
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, bottom: 15.0, top: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Reason for Leave:",
                      style: GoogleFonts.inter(),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Mytextfield(
                      bgColor: bgColor,
                      borderColor: borderColor,
                      borderRadius: borderRadius,
                      borderWidth: borderWidth,
                      controller: _reasonController,
                      hintColor: hintColor,
                      hinttext: "enter reason here",
                      textColor: textColor,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "From Date:",
                      style: GoogleFonts.inter(),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Mydate(
                      blockPastDates: true,
                      bgColor: bgColor,
                      borderColor: borderColor,
                      borderRadius: borderRadius,
                      borderWidth: borderWidth,
                      dateController: _fromController,
                      hintColor: hintColor,
                      hinttext: "leave begins on?",
                      textColor: textColor,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "To Date:",
                      style: GoogleFonts.inter(),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Mydate(
                      blockPastDates: true,
                      bgColor: bgColor,
                      borderColor: borderColor,
                      borderRadius: borderRadius,
                      borderWidth: borderWidth,
                      dateController: _toController,
                      hintColor: hintColor,
                      hinttext: "leave ends on?",
                      textColor: textColor,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text("Leave Type:", style: GoogleFonts.inter()),
                    SizedBox(
                      height: 10,
                    ),
                    Mydropdownmenu(
                        bgColor: bgColor,
                        borderColor: borderColor,
                        borderRadius: borderRadius,
                        borderWidth: borderWidth,
                        hintColor: hintColor,
                        textColor: textColor,
                        buttonColor: buttonColor,
                        list: [
                          "Casual",
                          "Medical",
                          "Exam Leave",
                          "Vacation Leave",
                          "Others"
                        ],
                        getvalue: (value) {
                          setState(() {
                            type = value;
                          });
                        }),
                    SizedBox(
                      height: 20,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          submit();
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(buttonColor),
                        ),
                        child: Text(
                          "Submit",
                          style: GoogleFonts.inter(
                              color: buttonTextColor,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  void submit() {
    String reason = _reasonController.text;
    String from = _fromController.text;
    String to = _toController.text;
    if (reason.isEmpty || from.isEmpty || to.isEmpty) {
      _showSnackBar("Please fill all the fields", isError: true);
      return;
    }
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentReference docRef =
            FirebaseFirestore.instance.collection("leave_application").doc();
        docRef.set({
          "student_id": user.uid,
          "reason": reason,
          "from": from,
          "to": to,
          "status": "pending",
          "created_at": FieldValue.serverTimestamp(),
          'type': type,
        });
        int score = ((scores!['score'] ?? 0) + 5);
        int leave = ((scores!['leave'] ?? 0) + 1);
        FirebaseFirestore.instance
            .collection("points")
            .doc(user.uid)
            .update({'score': score, 'leave': leave});
        String text = getBadges(scores!, 'leave');
        _showSnackBar("Leave application submitted successfully");
        if (text != "") {
          _celebrate("You've unlocked a new badge!", text);
        }
        // ignore: use_build_context_synchronously
        FocusScope.of(context).unfocus();
        Future.delayed(Duration(milliseconds: 500), () {
          if (context.mounted) {
            // ignore: use_build_context_synchronously
            Navigator.pop(context);
          }
        });
      } catch (e) {
        _showSnackBar("An error occured. Please try again", isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    Mysnackbar.show(context, message, isError: isError);
  }

  void _celebrate(String message, String special) {
    if (!mounted) return;
    Mysnackbar.celebrate(context, message, special);
  }
}
