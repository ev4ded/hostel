import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:minipro/student/components/mydate.dart';
import 'package:minipro/student/components/mydropdownmenu.dart';
import 'package:minipro/student/components/myparafield.dart';
import 'package:minipro/student/components/mysnackbar.dart';
import 'package:minipro/student/components/mytextfield.dart';

class Editprofile extends StatefulWidget {
  const Editprofile({super.key});

  @override
  State<Editprofile> createState() => _EditprofileState();
}

class _EditprofileState extends State<Editprofile> {
  final Color inputtextColor = Color.fromRGBO(240, 237, 235, 1);
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _dobController = TextEditingController();
  final _collegeNameController = TextEditingController();
  final _degreeController = TextEditingController();
  final double borderWidth = 1;
  final double borderRadius = 15;
  final Color borderColor = Color.fromRGBO(74, 85, 104, 1);
  Color textColor = Colors.white;
  Color bgColor = Color.fromRGBO(40, 40, 40, 1);
  Color hintColor = Color.fromRGBO(139, 139, 139, 0.5);
  Color buttonColor = Color.fromRGBO(255, 189, 109, 1);
  Color buttonTextColor = Color.fromRGBO(18, 18, 18, 1);
  Color highlightColor = Colors.blueAccent;
  String? gender;
  String? year;
  String? degree;
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LucideIcons.chevronLeft),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Profile Details",
          style: GoogleFonts.inter(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: height * 0.02,
                ),
                Text(
                  "Full Name:",
                  style: GoogleFonts.inter(),
                ),
                SizedBox(
                  height: height * 0.01,
                ),
                Mytextfield(
                  bgColor: bgColor,
                  borderColor: borderColor,
                  borderRadius: borderRadius,
                  borderWidth: borderWidth,
                  controller: _nameController,
                  hintColor: hintColor,
                  hinttext: "Enter your full name",
                  textColor: textColor,
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                Text(
                  "Bio:",
                  style: GoogleFonts.inter(),
                ),
                SizedBox(
                  height: height * 0.01,
                ),
                Myparafield(
                  bgColor: bgColor,
                  borderColor: borderColor,
                  borderRadius: borderRadius,
                  borderWidth: borderWidth,
                  controller: _bioController,
                  hintColor: hintColor,
                  hintText: "bio here",
                  noOfLine: 3,
                  textColor: textColor,
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                Text(
                  "College Name:",
                  style: GoogleFonts.inter(),
                ),
                SizedBox(
                  height: height * 0.01,
                ),
                Mytextfield(
                  bgColor: bgColor,
                  borderColor: borderColor,
                  borderRadius: borderRadius,
                  borderWidth: borderWidth,
                  controller: _collegeNameController,
                  hintColor: hintColor,
                  hinttext: "College Name",
                  textColor: textColor,
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                Text(
                  "Degree:",
                  style: GoogleFonts.inter(),
                ),
                SizedBox(
                  height: height * 0.01,
                ),
                Mydropdownmenu(
                  bgColor: bgColor,
                  borderColor: borderColor,
                  borderRadius: borderRadius,
                  borderWidth: borderWidth,
                  buttonColor: buttonColor,
                  getvalue: (value) {
                    setState(() {
                      degree = value;
                    });
                  },
                  list: [
                    "BTech",
                    "MBBS",
                    "BSc",
                    "BCom",
                    "BA",
                    "BBA",
                    "BCA",
                    "MBA",
                    "CA",
                    "LLB"
                  ],
                  hintColor: hintColor,
                  hinttext: "which degree",
                  textColor: textColor,
                  width: width,
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                Text(
                  "Year of study:",
                  style: GoogleFonts.inter(),
                ),
                SizedBox(
                  height: height * 0.01,
                ),
                Mydropdownmenu(
                  bgColor: bgColor,
                  borderColor: borderColor,
                  borderRadius: borderRadius,
                  borderWidth: borderWidth,
                  buttonColor: buttonColor,
                  getvalue: (value) {
                    setState(() {
                      year = value;
                    });
                  },
                  list: ["1st", "2nd", "3rd", "4th"],
                  hintColor: hintColor,
                  hinttext: "which year u currently at?",
                  textColor: textColor,
                  width: width,
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                Text(
                  "Date of Birth:",
                  style: GoogleFonts.inter(),
                ),
                SizedBox(
                  height: height * 0.01,
                ),
                Mydate(
                  bgColor: bgColor,
                  borderColor: borderColor,
                  borderRadius: borderRadius,
                  borderWidth: borderWidth,
                  datecontroller: _dobController,
                  hintColor: hintColor,
                  hinttext: "D.O.B",
                  textColor: textColor,
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                Text(
                  "Gender:",
                  style: GoogleFonts.inter(),
                ),
                SizedBox(
                  height: height * 0.01,
                ),
                Mydropdownmenu(
                  bgColor: bgColor,
                  borderColor: borderColor,
                  borderRadius: borderRadius,
                  borderWidth: borderWidth,
                  buttonColor: buttonColor,
                  getvalue: (value) {
                    setState(() {
                      gender = value;
                    });
                  },
                  list: ["Male", "Female", "Other"],
                  hintColor: hintColor,
                  hinttext: "gender",
                  textColor: textColor,
                  width: width,
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: SizedBox(
                      width: width * 0.35,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.all(buttonColor)),
                        child: Text(
                          "Submit",
                          style: GoogleFonts.inter(
                              color: buttonTextColor,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void submit() {
    String name = _nameController.toString().trim();
    String bio = _bioController.toString().trim();
    String collegeName = _collegeNameController.toString().trim();
    String dob = _dobController.toString().trim();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        FirebaseFirestore.instance.collection("Udetails").doc(user.uid).set(
          {
            'full_name': name,
            'bio': bio,
            'college_name': collegeName,
            'degree': degree ?? "",
            'year': year ?? "",
            'dob': dob,
            'gender': gender ?? ""
          },
        );
        _showSnackBar("profile updated successfully");
      } catch (e) {
        _showSnackBar("error:$e");
      }
    }
    _showSnackBar("user not found");
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    Mysnackbar.show(context, message, isError: isError);
  }
}
