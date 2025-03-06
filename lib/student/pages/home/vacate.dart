import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:minipro/student/Student_queries/queries.dart';
import 'package:minipro/Theme/appcolors.dart';
import 'package:minipro/student/components/mydate.dart';
import 'package:minipro/student/components/mydropdownmenu.dart';
import 'package:minipro/student/components/myparafield.dart';
import 'package:minipro/student/components/mysnackbar.dart';
import 'package:slider_button/slider_button.dart';
import 'package:minipro/firebase/firestore_services.dart';

class Vacate extends StatefulWidget {
  const Vacate({super.key});

  @override
  State<Vacate> createState() => _VacateState();
}

class _VacateState extends State<Vacate> {
  final _dateController = TextEditingController();
  final _addressController = TextEditingController();
  final double borderWidth = 1;
  final double borderRadius = 15;
  final Color borderColor = AppColors.borderColor;
  Color hintColor = AppColors.hintColor;
  Color buttonColor = AppColors.buttonColor;
  Color buttonTextColor = AppColors.buttonTextColor;
  Color highlightColor = Colors.blueAccent;
  String today = DateFormat("yyyy-MM-dd").format(DateTime.now());
  List<String> reasons = [
    "Graduation Completed",
    "End of Semester Break",
    "Shifting to Another Hostel",
    "Financial Issues",
    "Personal Reasons",
    "Health Issues",
    "Disciplinary Action",
    "Roommate Issues",
    "Better Accommodation Found",
    "Other"
  ];
  String? reason;
  Map<String, dynamic>? userData;
  final FirestoreServices _firestoreService = FirestoreServices();
  User? user = FirebaseAuth.instance.currentUser;
  bool isloading = true;
  bool isApplied = false;
  @override
  void initState() {
    super.initState();
    fetchUserData();
    applied();
  }

  void fetchUserData() async {
    Map<String, dynamic>? cachedUserData =
        await _firestoreService.getCachedUserData();
    if (cachedUserData != null) {
      setState(() {
        userData = cachedUserData;
      });
    } else {
      await _firestoreService.getUserData();
      Map<String, dynamic>? newUserData =
          await _firestoreService.getCachedUserData();
      setState(
        () {
          userData = newUserData;
        },
      );
    }
  }

  void applied() async {
    setState(() {
      isloading = true;
    });
    try {
      bool did = await appliedForVacate();
      setState(() {
        isApplied = did;
        isloading = false;
      });
      if (did) {
        _showAppliedDialog();
      }
    } catch (e) {
      setState(() {
        isloading = false;
      });
      _showSnackBar("message:$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    Color textColor = AppColors.getTextColor(context);
    Color bgColor = AppColors.getContainerColor(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(LucideIcons.chevronLeft),
        ),
        title: Text(
          "Vacate Request",
          style: GoogleFonts.inter(),
        ),
      ),
      body: isloading
          ? Center(child: CircularProgressIndicator())
          : isApplied
              ? SizedBox()
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: height * 0.03,
                        ),
                        Text(
                          "Date",
                          style: GoogleFonts.inter(),
                        ),
                        SizedBox(
                          height: height * 0.02,
                        ),
                        Mydate(
                          hinttext: "Vacating date?",
                          bgColor: bgColor,
                          borderColor: borderColor,
                          borderRadius: borderRadius,
                          borderWidth: borderWidth,
                          dateController: _dateController,
                          hintColor: hintColor,
                          textColor: textColor,
                        ),
                        SizedBox(
                          height: height * 0.02,
                        ),
                        Text("Reason"),
                        SizedBox(
                          height: height * 0.02,
                        ),
                        Mydropdownmenu(
                          bgColor: bgColor,
                          borderColor: borderColor,
                          borderRadius: borderRadius,
                          borderWidth: borderWidth,
                          buttonColor: buttonColor,
                          getvalue: (value) {
                            setState(
                              () {
                                reason = value;
                              },
                            );
                          },
                          hintColor: hintColor,
                          hinttext: "Reason?",
                          list: reasons,
                          textColor: textColor,
                          width: width,
                        ),
                        SizedBox(
                          height: height * 0.02,
                        ),
                        Text("Forwarding Address"),
                        SizedBox(
                          height: height * 0.02,
                        ),
                        Myparafield(
                          bgColor: bgColor,
                          borderColor: borderColor,
                          borderRadius: borderRadius,
                          borderWidth: borderWidth,
                          controller: _addressController,
                          hintColor: hintColor,
                          hintText: "address here",
                          textColor: textColor,
                          noOfLine: 3,
                        ),
                        SizedBox(
                          height: height * 0.05,
                        ),
                        Center(
                          child: SliderButton(
                            action: () async {
                              bool success = await submit();
                              if (success) {
                                Future.delayed(
                                  Duration(seconds: 1),
                                  () {
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                    }
                                  },
                                );
                                return true;
                              }
                              return false;
                            },
                            label: Text(
                              "Slide to apply",
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w500),
                            ),
                            backgroundColor: bgColor,
                            icon: Icon(
                              LucideIcons.chevronsRight,
                              color: buttonTextColor,
                              size: width * 0.1,
                            ),
                            buttonColor: buttonColor,
                            baseColor: textColor,
                            highlightedColor: buttonTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    Mysnackbar.show(context, message, isError: isError);
  }

  Future<bool> submit() async {
    String date = _dateController.text.trim();
    String address = _addressController.text.trim();
    if (date.isEmpty || address.isEmpty || reason == null) {
      _showSnackBar("please fill in all fields", isError: true);
      return false;
    }
    if ((DateTime.parse(date)).isBefore(DateTime.parse(today))) {
      _showSnackBar("check the date stupid");
      return false;
    }
    if (await showAlert(context) == false) {
      return false;
    }
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        FirebaseFirestore.instance.collection("vacate").doc(user.uid).set(
          {
            'name': userData!["username"],
            'student_id': user.uid,
            'hostel_id': userData!["hostelId"],
            'vacting_date': date,
            'address': address,
            'reason': reason,
            'room_no': userData!["room_no"],
          },
        );
        _showSnackBar("vacate request send");
        return true;
      } catch (e) {
        _showSnackBar("request failed:$e");
        return false;
      }
    }
    return false;
  }

  void _showAppliedDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: AppColors.getContainerColor(context),
            title: Text("Already Applied"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("You have already applied for vacating"),
                Image.asset("assets/images/confusion.png"),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(buttonColor)),
                  child: Text(
                    "close",
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700, color: buttonTextColor),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Future<bool> showAlert(BuildContext context) async {
    bool status = false;
    status = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Alert",
            style: GoogleFonts.inter(),
          ),
          content: Text(
            "are you sure u wanna vacate?",
            style: GoogleFonts.inter(),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(buttonColor),
              ),
              child: Text(
                "cancel",
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700, color: buttonTextColor),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(buttonColor),
              ),
              child: Text(
                "yes",
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700, color: buttonTextColor),
              ),
            ),
          ],
        );
      },
    );
    return status;
  }
}
