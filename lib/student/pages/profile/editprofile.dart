import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:minipro/Theme/appcolors.dart';
import 'package:minipro/firebase/firestore_services.dart';
import 'package:minipro/student/components/mydate.dart';
import 'package:minipro/student/components/mydropdownmenu.dart';
import 'package:minipro/student/components/mysnackbar.dart';
import 'package:minipro/student/components/mytextfield.dart';

class Editprofile extends StatefulWidget {
  const Editprofile({super.key});

  @override
  State<Editprofile> createState() => _EditprofileState();
}

class _EditprofileState extends State<Editprofile> {
  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  final _collageNameController = TextEditingController();
  String degree = "";
  String gender = "";
  String yearOfStudy = "";
  final double borderWidth = 1;
  final double borderRadius = 15;
  final Color borderColor = AppColors.borderColor;
  Color hintColor = AppColors.hintColor;
  Color buttonColor = AppColors.buttonColor;
  Color buttonTextColor = AppColors.buttonTextColor;
  final int year = DateTime.now().year;
  final FirestoreServices _firestoreService = FirestoreServices();
  Map<String, dynamic>? userDetails;
  bool isloading = true;

  @override
  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  void fetchUserDetails() async {
    Map<String, dynamic>? userDetails =
        await _firestoreService.getUserDetails();
    if (userDetails != null) {
      setState(() {
        _nameController.text = userDetails["full_name"] ?? "";
        _collageNameController.text = userDetails["college_name"] ?? "";
        _dateController.text = userDetails["dob"] ?? "";
        degree = userDetails["degree"] ?? "";
        yearOfStudy = userDetails["year_of_study"] ?? "";
        _dateController.text = userDetails["dob"] ?? "";
        gender = userDetails["gender"] ?? "";
        isloading = false;
      });
    } else {
      setState(() {
        isloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = AppColors.getTextColor(context);
    Color bgColor = AppColors.getContainerColor(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile Details",
          style: GoogleFonts.inter(),
        ),
        leading: IconButton(
          icon: Icon(LucideIcons.chevronLeft),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isloading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 10, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Full Name:",
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
                      controller: _nameController,
                      hintColor: hintColor,
                      hinttext: "Enter your full name",
                      textColor: textColor,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "College Name:",
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
                      controller: _collageNameController,
                      hintColor: hintColor,
                      hinttext: "Enter your college name",
                      textColor: textColor,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Degree:",
                      style: GoogleFonts.inter(),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Mydropdownmenu(
                      list: ["B.Tech", "M.Tech", "MBA", "BBA", "BCA"],
                      bgColor: bgColor,
                      borderColor: borderColor,
                      borderRadius: borderRadius,
                      borderWidth: borderWidth,
                      buttonColor: buttonColor,
                      hintColor: hintColor,
                      hinttext: degree.isEmpty ? "choose your degree" : degree,
                      textColor: textColor,
                      defaultvalue: degree.isNotEmpty &&
                              ["B.Tech", "M.Tech", "MBA", "BBA", "BCA"]
                                  .contains(degree)
                          ? degree
                          : null,
                      getvalue: (value) {
                        setState(() {
                          degree = value;
                        });
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Year of Study:",
                      style: GoogleFonts.inter(),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Mydropdownmenu(
                      list: ["1st", "2nd", "3rd", "4th"],
                      bgColor: bgColor,
                      borderColor: borderColor,
                      borderRadius: borderRadius,
                      borderWidth: borderWidth,
                      buttonColor: buttonColor,
                      hintColor: hintColor,
                      hinttext: yearOfStudy.isEmpty
                          ? "Select which year"
                          : yearOfStudy,
                      textColor: textColor,
                      defaultvalue: yearOfStudy.isNotEmpty &&
                              ["1st", "2nd", "3rd", "4th"].contains(yearOfStudy)
                          ? yearOfStudy
                          : null,
                      getvalue: (value) {
                        setState(() {
                          yearOfStudy = value;
                        });
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "DOB:",
                      style: GoogleFonts.inter(),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Mydate(
                      hinttext: "Select your DOB",
                      borderColor: borderColor,
                      borderWidth: borderWidth,
                      borderRadius: borderRadius,
                      bgColor: bgColor,
                      hintColor: hintColor,
                      textColor: textColor,
                      dateController: _dateController,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Gender:",
                      style: GoogleFonts.inter(),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Mydropdownmenu(
                      list: ["Male", "Female", "Other"],
                      bgColor: bgColor,
                      borderColor: borderColor,
                      borderRadius: borderRadius,
                      borderWidth: borderWidth,
                      buttonColor: buttonColor,
                      hintColor: hintColor,
                      hinttext: gender.isEmpty ? "Select your gender" : gender,
                      textColor: textColor,
                      defaultvalue: gender.isNotEmpty &&
                              ["Male", "Female", "Other"].contains(gender)
                          ? gender
                          : null,
                      getvalue: (value) {
                        setState(() {
                          gender = value;
                        });
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: () {
                          submit();
                        },
                        style: ButtonStyle(
                            backgroundColor:
                                WidgetStatePropertyAll(buttonColor)),
                        child: Text("Save",
                            style: GoogleFonts.inter(
                                color: buttonTextColor,
                                fontWeight: FontWeight.w600)),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  void submit() {
    String name = _nameController.text;
    String college = _collageNameController.text;
    String dob = _dateController.text;
    if (name.isEmpty ||
        college.isEmpty ||
        dob.isEmpty ||
        degree.isEmpty ||
        yearOfStudy.isEmpty ||
        gender.isEmpty) {
      _showSnackBar("please fill in all fields", isError: true);
    } else {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          DocumentReference docRef =
              FirebaseFirestore.instance.collection("Udetails").doc(user.uid);
          docRef.set(
            {
              'full_name': name,
              'college_name': college,
              'degree': degree,
              'year_of_study': yearOfStudy,
              'dob': dob,
              'gender': gender,
            },
          );
          FirebaseFirestore.instance.collection("users").doc(user.uid).update({
            'username': name,
            'college': college,
          });
          _showSnackBar("upated successfully");
          Future.delayed(Duration(seconds: 1), () {
            if (context.mounted) {
              Navigator.pop(context);
            }
          });
        } catch (e) {
          _showSnackBar("updation failed");
        }
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    Mysnackbar.show(context, message, isError: isError);
  }
}
