import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:minipro/student/Student_queries/queries.dart';
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
  final Color inputtextColor = Color.fromRGBO(240, 237, 235, 1);
  final _dateController = TextEditingController();
  final _addressController = TextEditingController();
  final double borderWidth = 1;
  final double borderRadius = 15;
  final Color borderColor = Color.fromRGBO(74, 85, 104, 1);
  Color textColor = Colors.white;
  Color bgColor = Color.fromRGBO(40, 40, 40, 1);
  Color hintColor = Color.fromRGBO(139, 139, 139, 0.5);
  Color buttonColor = Color.fromRGBO(255, 189, 109, 1);
  Color buttonTextColor = Color.fromRGBO(18, 18, 18, 1);
  Color highlightColor = Colors.blueAccent;
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
  bool isApplied = false;
  @override
  void initState() {
    super.initState();
    fetchUserData();
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
      setState(() {
        userData = newUserData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
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
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
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
                    datecontroller: _dateController,
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
                      setState(() {
                        reason = value;
                      });
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
                        submit();
                        Future.delayed(Duration(seconds: 1), () {
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        });
                        return true;
                      },
                      label: Text(
                        "Slide to apply",
                        style: GoogleFonts.inter(fontWeight: FontWeight.w500),
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
        ));
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    Mysnackbar.show(context, message, isError: isError);
  }

  void submit() async {
    String date = _dateController.text.trim();
    String address = _addressController.text.trim();
    if (date.isEmpty || address.isEmpty || reason == null) {
      _showSnackBar("please fill in all fields", isError: true);
      return;
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
      } catch (e) {
        _showSnackBar("request failed:$e");
      }
    }
  }
}
