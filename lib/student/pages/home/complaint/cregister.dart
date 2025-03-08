import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minipro/firebase/firestore_services.dart';
import 'package:minipro/Theme/appcolors.dart';
import 'package:minipro/student/components/mydropdownmenu.dart';
import 'package:minipro/student/components/myparafield.dart';
import 'package:minipro/student/components/mysnackbar.dart';
import 'package:minipro/student/components/mytextfield.dart';

class Cregister extends StatefulWidget {
  const Cregister({super.key});

  @override
  State<Cregister> createState() => _CregisterState();
}

class _CregisterState extends State<Cregister> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final double borderWidth = 1;
  final double borderRadius = 15;
  final Color borderColor = Color.fromRGBO(74, 85, 104, 1);
  Color hintColor = AppColors.hintColor;
  Color buttonColor = Color.fromRGBO(255, 189, 109, 1);
  Color buttonTextColor = Color.fromRGBO(18, 18, 18, 1);
  final int year = DateTime.now().year;
  final FirestoreServices _firestoreService = FirestoreServices();
  Map<String, dynamic>? userData;
  List<String> priorityList = ["ciritcal", "high", "moderate", "low"];
  String? priority;

  @override
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
    double width = MediaQuery.of(context).size.width;
    Color bgColor = AppColors.getContainerColor(context);
    Color textColor = AppColors.getTextColor(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Complaint Register",
          style: GoogleFonts.poppins(),
        ),
      ),
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                "Issue",
                style: GoogleFonts.inter(),
              ),
              SizedBox(
                height: 10,
              ),
              Mytextfield(
                controller: _titleController,
                textColor: textColor,
                borderRadius: borderRadius,
                borderColor: borderColor,
                hinttext: "what's the issue?",
                bgColor: bgColor,
                hintColor: hintColor,
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                "Description",
                style: GoogleFonts.inter(),
              ),
              SizedBox(
                height: 10,
              ),
              Myparafield(
                controller: _descController,
                borderColor: borderColor,
                textColor: textColor,
                bgColor: bgColor,
                hintColor: hintColor,
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                "Priority",
                style: GoogleFonts.inter(),
              ),
              SizedBox(
                height: 10,
              ),
              Mydropdownmenu(
                  buttonColor: buttonColor,
                  hinttext: "Priority",
                  hintColor: hintColor,
                  bgColor: bgColor,
                  borderColor: borderColor,
                  borderWidth: borderWidth,
                  borderRadius: borderRadius,
                  list: priorityList,
                  textColor: textColor,
                  width: width,
                  getvalue: (value) {
                    setState(() {
                      priority = value;
                    });
                  }),
              SizedBox(
                height: 30,
              ),
              Align(
                alignment: Alignment.topRight,
                child: SizedBox(
                  height: 50,
                  width: width,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all(buttonColor)),
                      onPressed: () {
                        submit();
                      },
                      child: Text(
                        "SUBMIT",
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            color: buttonTextColor,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void submit() async {
    String title = _titleController.text.trim();
    String description = _descController.text.trim();
    if (title.isEmpty || description.isEmpty || priority == null) {
      _showSnackBar("please fill in all fields", isError: true);
      return;
    }
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentReference docRef =
            FirebaseFirestore.instance.collection("complaints").doc();
        docRef.set(
          {
            'request_id': docRef.id,
            'student_id': user.uid,
            'hostel_id': userData!["hostelId"],
            'title': title,
            'status': 'pending',
            'priority': priority,
            'room_no': userData!["room_no"],
            'description': description,
            'created_at': FieldValue.serverTimestamp(),
          },
        );
        _showSnackBar("request send");
        Future.delayed(Duration(seconds: 1), () {
          if (context.mounted) {
            Navigator.pop(context);
          }
        });
      } catch (e) {
        _showSnackBar("request failed");
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    Mysnackbar.show(context, message, isError: isError);
  }
}
