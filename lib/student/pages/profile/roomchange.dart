import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:minipro/Theme/appcolors.dart';
import 'package:minipro/firebase/firestore_services.dart';
import 'package:minipro/student/components/myparafield.dart';
import 'package:minipro/student/components/mysnackbar.dart';

class Roomchange extends StatefulWidget {
  const Roomchange({super.key});

  @override
  State<Roomchange> createState() => _RoomchangeState();
}

class _RoomchangeState extends State<Roomchange> {
  final Color borderColor = AppColors.borderColor;
  Color hintColor = AppColors.hintColor;
  Color buttonColor = AppColors.buttonColor;
  Color buttonTextColor = AppColors.buttonTextColor;
  final double borderWidth = 1;
  final double borderRadius = 15;
  final _reasonController = TextEditingController();
  final FirestoreServices _firestoreServices = FirestoreServices();
  String? status;
  String name = "";
  String gender = "";
  bool isloading = true;
  String img = "cat";
  String roomno = "";
  String reason = "";

  @override
  void initState() {
    super.initState();
    fetchStatus();
  }

  void fetchStatus() async {
    Map<String, dynamic>? userDetails =
        await _firestoreServices.getUserDetails();
    if (userDetails != null) {
      setState(() {
        name = userDetails["username"];
        gender = userDetails["gender"] ?? "";
        if (gender == "" || gender == "Other") {
          img = "cat";
        } else {
          img = gender;
        }
      });
    }
    List read = await _firestoreServices.getRoomChangeStatus();
    setState(
      () {
        status = read[0];
        //status = status!.trim();
        if (status == "approved") {
          roomno = read[1];
        } else if (status == "denied") {
          reason = read[1] ?? "";
        }
        isloading = false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room change', style: GoogleFonts.inter()),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(LucideIcons.chevronLeft),
        ),
      ),
      body: Center(
        child: isloading ? CircularProgressIndicator() : getContainer(),
      ),
    );
  }

  Widget getContainer() {
    Color textColor = AppColors.getTextColor(context);
    Color bgColor = AppColors.getContainerColor(context);
    double width = MediaQuery.of(context).size.width;
    if (status == "") {
      return Wrap(
        children: [
          Container(
            width: width * 0.95,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20.0, right: 10.0, top: 10.0),
                  child: Text(
                    "Reason:",
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                  child: Myparafield(
                    bgColor: bgColor,
                    borderColor: borderColor,
                    borderRadius: borderRadius,
                    borderWidth: borderWidth,
                    controller: _reasonController,
                    hintColor: hintColor,
                    hintText: "why you wanna change room?",
                    noOfLine: 4,
                    textColor: textColor,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: ElevatedButton(
                      onPressed: () {
                        submit();
                      },
                      style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(buttonColor)),
                      child: Text(
                        "Apply",
                        style: GoogleFonts.inter(
                            color: buttonTextColor,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      );
    } else if (status == "pending") {
      return Wrap(
        children: [
          Container(
            height: 290,
            width: width * 0.8,
            decoration: BoxDecoration(
              color: AppColors.getAlertWindowC(context),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 200,
                  child: Image(
                    image: AssetImage("assets/images/waiting$img.png"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "your request is still pending..",
                    style: GoogleFonts.inter(color: textColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else if (status == "approved") {
      return Wrap(
        children: [
          Container(
            width: width * 0.75,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "your request has been approved",
                    style: GoogleFonts.inter(color: Colors.lightGreen),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      "new room no: $roomno",
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20.0, bottom: 10),
                      child: ElevatedButton(
                        onPressed: () {
                          accept();
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(buttonColor),
                        ),
                        child: Text(
                          "accept",
                          style: GoogleFonts.inter(
                              color: buttonTextColor,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      );
    } else if (status == "denied") {
      return Wrap(
        children: [
          Container(
            width: width * 0.75,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Request has been denied",
                    style: GoogleFonts.inter(color: Colors.red),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Text(
                      "reason: $reason",
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20.0, bottom: 10),
                      child: ElevatedButton(
                        onPressed: () {
                          accept();
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(buttonColor),
                        ),
                        child: Text(
                          "OK",
                          style: GoogleFonts.inter(
                              color: buttonTextColor,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return Container(
        child: Text("else"),
      );
    }
  }

  void submit() {
    if (_reasonController.text.isEmpty) {
      _showSnackBar("please fill in all fields", isError: true);
    } else {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          DocumentReference docRef = FirebaseFirestore.instance
              .collection("room_change")
              .doc(user.uid);
          docRef.set(
            {
              'description': _reasonController.text,
              'name': name,
              'status': "pending",
            },
          );
          _showSnackBar("applied successfully");
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
  }

  Future<void> accept() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection("room_change")
            .doc(user.uid)
            .delete();
        //_showSnackBar("room allocated successfully");
        Future.delayed(Duration(seconds: 1), () {
          if (context.mounted) {
            Navigator.pop(context);
          }
        });
      } catch (e) {
        print("error:$e");
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    Mysnackbar.show(context, message, isError: isError);
  }
}
