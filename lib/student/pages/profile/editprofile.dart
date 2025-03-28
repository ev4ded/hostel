import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:minipro/Theme/appcolors.dart';
import 'package:minipro/firebase/firestore_services.dart';
import 'package:minipro/student/components/custom_route.dart';
import 'package:minipro/student/components/mydate.dart';
import 'package:minipro/student/components/mydropdownmenu.dart';
import 'package:minipro/student/components/mysnackbar.dart';
import 'package:minipro/student/components/mytextfield.dart';
import 'package:minipro/student/pages/navigator.dart';

class Studenteditprofile extends StatefulWidget {
  const Studenteditprofile({super.key});

  @override
  State<Studenteditprofile> createState() => _StudenteditprofileState();
}

class _StudenteditprofileState extends State<Studenteditprofile> {
  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  final _collageNameController = TextEditingController();
  final _phoneController = TextEditingController();
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
  bool profileUpdated = false;

  @override
  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    setState(() {
      isloading = true;
    });
    Map<String, dynamic>? cachedUserData =
        await _firestoreService.getCachedUserData();
    if (cachedUserData == null) {
      await _firestoreService.getUserData();
      cachedUserData = await _firestoreService.getCachedUserData();
    }
    if (cachedUserData != null) {
      setState(() {
        _nameController.text = cachedUserData?["username"] ?? "";
        _collageNameController.text = cachedUserData?["college_name"] ?? "";
        _dateController.text = cachedUserData?["dob"] ?? "";
        degree = cachedUserData?["degree"] ?? "";
        yearOfStudy = cachedUserData?["year_of_study"] ?? "";
        _dateController.text = cachedUserData?["dob"] ?? "";
        _phoneController.text = (cachedUserData?["phone_no"] ?? "").toString();
        gender = cachedUserData?["gender"] ?? "";
        isloading = false;
        profileUpdated = cachedUserData?['profileUpdated'] ?? false;
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
          leading: (profileUpdated)
              ? IconButton(
                  icon: Icon(LucideIcons.chevronLeft),
                  onPressed: () {
                    Navigator.push(
                      context,
                      myRoute(
                        MainNavigator(
                          pageno: 2,
                        ),
                      ),
                    );
                  },
                )
              : Icon(LucideIcons.chevronLeft, color: Colors.grey)),
      body: PopScope(
        canPop: profileUpdated,
        child: isloading
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
                        hinttext:
                            degree.isEmpty ? "choose your degree" : degree,
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
                                ["1st", "2nd", "3rd", "4th"]
                                    .contains(yearOfStudy)
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
                        "Phone no:",
                        style: GoogleFonts.inter(),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Mytextfield(
                        type: TextInputType.number,
                        bgColor: bgColor,
                        borderColor: borderColor,
                        borderRadius: borderRadius,
                        borderWidth: borderWidth,
                        controller: _phoneController,
                        hintColor: hintColor,
                        hinttext: "Enter phone no",
                        textColor: textColor,
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
                        hinttext:
                            gender.isEmpty ? "Select your gender" : gender,
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
                          child: Text(
                            "Save",
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
      ),
    );
  }

  Future<void> submit() async {
    String name = _nameController.text;
    String college = _collageNameController.text;
    String dob = _dateController.text;
    String phone = _phoneController.text;
    if (name.isEmpty ||
        college.isEmpty ||
        dob.isEmpty ||
        degree.isEmpty ||
        yearOfStudy.isEmpty ||
        gender.isEmpty ||
        phone.isEmpty) {
      _showSnackBar("please fill in all fields", isError: true);
    } else if (!isValidPhoneNumber(phone)) {
      _showSnackBar("enter a valid phone number", isError: true);
    } else {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          DocumentReference docRef =
              FirebaseFirestore.instance.collection("users").doc(user.uid);
          await docRef.update(
            {
              'username': name,
              'college_name': college,
              'degree': degree,
              'year_of_study': yearOfStudy,
              'dob': dob,
              'gender': gender,
              'phone_no': phone,
              "profileUpdated": true,
            },
          );
          /*_firestoreService.userDocument.update({
            "profileUpdated": true, // Mark as updated
          });*/
          _showSnackBar("Upated successfully");
          Future.delayed(Duration(seconds: 1), () {
            if (context.mounted) {
              Navigator.push(
                context,
                myRoute(
                  MainNavigator(
                    pageno: 2,
                  ),
                ),
              );
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

  bool isValidPhoneNumber(String number) {
    RegExp regex = RegExp(
        r'^[6789]\d{9}$'); // Indian numbers start with 6,7,8,9 and have 10 digits
    return regex.hasMatch(number);
  }
}
