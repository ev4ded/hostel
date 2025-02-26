import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minipro/firebase/firestore_services.dart';
import 'package:minipro/student/components/myparafield.dart';
import 'package:minipro/student/components/mysnackbar.dart';
import 'package:minipro/student/components/mytextfield.dart';

class MaintenanceRequest extends StatefulWidget {
  const MaintenanceRequest({super.key});

  @override
  State<MaintenanceRequest> createState() => _MaintenanceState();
}

class _MaintenanceState extends State<MaintenanceRequest> {
  final Color inputtextColor = Color.fromRGBO(240, 237, 235, 1);
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final double borderWidth = 1;
  final double borderRadius = 15;
  final Color borderColor = Color.fromRGBO(74, 85, 104, 1);
  Color textColor = Colors.white;
  Color bgColor = Color.fromRGBO(40, 40, 40, 1);
  Color hintColor = Color.fromRGBO(139, 139, 139, 0.5);
  Color buttonColor = Color.fromRGBO(255, 189, 109, 1);
  Color buttonTextColor = Color.fromRGBO(18, 18, 18, 1);
  final int year = DateTime.now().year;
  final FirestoreServices _firestoreService = FirestoreServices();
  Map<String, dynamic>? userData;

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
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 13.0),
          child: Text(
            "Maintenance Request",
            style: GoogleFonts.poppins(),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                "Title",
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
                hinttext: "enter title here",
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
                        Future.delayed(Duration(seconds: 1), () {
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        });
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
    if (title.isEmpty || description.isEmpty) {
      _showSnackBar("please fill in all fields", isError: true);
      return;
    }
    User? user = FirebaseAuth.instance.currentUser;
    //_showSnackBar(user.toString());
    //if (user != null) ;
    //print("title:$title\ndesciption:$description\nuser:${user.uid}");*/
    //await FirebaseAuth.instance.currentUser?.getIdToken(true);
    if (user != null) {
      //_showSnackBar()
      try {
        DocumentReference docRef =
            FirebaseFirestore.instance.collection("maintenance_request").doc();
        docRef.set(
          {
            'request_id': docRef.id,
            'student_id': user.uid,
            'hostel_id': userData!["hostelId"],
            'title': title,
            'status': 'pending',
            'room_no': userData!["room_no"],
            'description': description,
            'created_at': FieldValue.serverTimestamp(),
          },
        );
        _showSnackBar("request send");
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
