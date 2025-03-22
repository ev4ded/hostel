import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:minipro/Admin/adminqueries.dart';
import 'package:minipro/authentication/fcmtoken.dart';
import 'package:minipro/firebase/firestore_services.dart';
import 'package:minipro/authentication/loginpage.dart';
import 'package:minipro/Theme/appcolors.dart';
import 'package:minipro/student/components/custom_route.dart';
import 'package:minipro/student/components/customProfilepopUp.dart';
import 'package:minipro/student/components/mysnackbar.dart';
import 'package:minipro/student/pages/profile/changepassword.dart';
import 'package:minipro/student/pages/profile/editprofile.dart';
import 'package:minipro/student/pages/profile/help.dart';
import 'package:minipro/student/pages/profile/roomchange.dart';
import 'package:minipro/student/pages/profile/userguidelines.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  final FirestoreServices _firestoreService = FirestoreServices();
  Map<String, dynamic>? userData;
  Map<String, dynamic>? hostel;
  Color flipC = Color.fromRGBO(237, 208, 176, 1);
  bool present = true;
  String name = "profile";
  static const double allowedRadius = 500;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool isloading = false;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: pi).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    fetchUserData();
    _loadProfileImage();
    listenToUserUpdates();
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
    setState(() {
      present = userData!['present'] ?? true;
    });
    Map<String, dynamic>? temp = await getHostelDetails(userData!["hostelId"]);
    if (temp != null) {
      hostel = temp;
    }
    print("present::$present");
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    Color containerColor = AppColors.getContainerColor(context);
    Color detailsC = AppColors.buttonColor;
    Color buttonTextC = AppColors.buttonTextColor;
    print("present:::$present");
    return Scaffold(
      body: userData == null
          ? Center(
              child:
                  CircularProgressIndicator()) // Loading indicator in the center
          : SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: 30),
                      Center(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    HapticFeedback.vibrate();
                                    String? imagename =
                                        await customImageSuggest(context);
                                    if (imagename != null) {
                                      setState(() {
                                        name = imagename;
                                        _saveProfileImage(name);
                                      });
                                      updateP(imagename);
                                    }
                                  },
                                  child: Container(
                                    width: 120, // Outer circle size
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: AppColors.textColorLight,
                                          width: 2), // Border color & width
                                    ),
                                    child: CircleAvatar(
                                      radius: 55,
                                      backgroundColor:
                                          Color.fromRGBO(93, 101, 95, 1),
                                      key: ValueKey(name),
                                      backgroundImage: name.isNotEmpty
                                          ? Image.asset(
                                                  "assets/images/profile/${userData!["dp"]}.jpg")
                                              .image
                                          : Image.asset(
                                                  "assets/images/profile/profile.png")
                                              .image,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Text(
                                        userData!["username"] ??
                                            "Username", // Safely handle null
                                        style:
                                            GoogleFonts.poppins(fontSize: 20),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        // Role
                                        Container(
                                            height: 38,
                                            width: 100,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              color: detailsC,
                                            ),
                                            child: Center(
                                              child: Text(
                                                userData!["college_name"] ??
                                                    userData![
                                                        "role"], // Safely handle null
                                                style: GoogleFonts.poppins(
                                                    fontSize: 18,
                                                    color: buttonTextC),
                                              ),
                                            )),
                                        SizedBox(width: 8),
                                        Container(
                                          height: 38,
                                          width: 100,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: detailsC,
                                          ),
                                          child: Center(
                                            child: Text(
                                              userData!["room_no"] ??
                                                  "Room ID", // Safely handle null
                                              style: GoogleFonts.poppins(
                                                  fontSize: 18,
                                                  color: buttonTextC),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                            SizedBox(height: 30),
                            GestureDetector(
                              onTap: updateStudentStatus,
                              child: AnimatedBuilder(
                                animation: _animation,
                                builder: (context, child) {
                                  double tilt =
                                      _animation.value > pi / 2 ? pi : 0;
                                  return Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.rotationY(
                                        _animation.value + tilt),
                                    child: Container(
                                      height: 150,
                                      width: 150,
                                      decoration: BoxDecoration(
                                        color: present
                                            ? Color.fromRGBO(197, 168, 136, 1)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: present
                                          ? Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      width: 5,
                                                      color: Color.fromRGBO(
                                                          197, 168, 136, 1)),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Image.asset(
                                                "assets/images/cutepng.png",
                                                fit: BoxFit.fill,
                                              ))
                                          : Container(
                                              decoration: BoxDecoration(
                                                  color: Color.fromRGBO(
                                                      197, 168, 136, 1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                            ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 30),
                            GestureDetector(
                              child: Container(
                                height: 50,
                                width: width,
                                decoration: BoxDecoration(
                                  color: containerColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 12.0),
                                        child: Icon(LucideIcons.edit),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          "Edit Profile",
                                          style:
                                              GoogleFonts.poppins(fontSize: 18),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  myRoute(
                                    Editprofile(),
                                  ),
                                );
                                HapticFeedback.heavyImpact();
                              },
                            ),
                            SizedBox(height: 5),
                            GestureDetector(
                              child: Container(
                                height: 50,
                                width: width,
                                decoration: BoxDecoration(
                                  color: containerColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 12.0),
                                        child: Icon(LucideIcons.doorOpen),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          "Room change?",
                                          style:
                                              GoogleFonts.poppins(fontSize: 18),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              onTap: () {
                                Roomchange();
                                Navigator.push(
                                  context,
                                  myRoute(
                                    Roomchange(),
                                  ),
                                );
                                HapticFeedback.heavyImpact();
                              },
                            ),
                            SizedBox(height: 5),
                            GestureDetector(
                              child: Container(
                                height: 50,
                                width: width,
                                decoration: BoxDecoration(
                                  color: containerColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 12.0),
                                        child: Icon(LucideIcons.keySquare),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          "change password",
                                          style:
                                              GoogleFonts.poppins(fontSize: 18),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  myRoute(Changepassword()),
                                );
                                HapticFeedback.heavyImpact();
                              },
                            ),
                            SizedBox(height: 5),
                            GestureDetector(
                              child: Container(
                                height: 50,
                                width: width,
                                decoration: BoxDecoration(
                                  color: containerColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 12.0),
                                        child: Icon(LucideIcons.logOut),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          "Sign Out",
                                          style:
                                              GoogleFonts.poppins(fontSize: 18),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              onTap: () {
                                HapticFeedback.heavyImpact();
                                customPopup(
                                  context,
                                  "Are you sure to sign out?",
                                  () {
                                    FirebaseAuth.instance.signOut();
                                    saveLoginState(false);
                                    User? userid =
                                        FirebaseAuth.instance.currentUser;
                                    removeFCMToken(userid!.uid);
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      myRoute(
                                        LoginPage(),
                                      ),
                                      (route) => false,
                                    );
                                  },
                                );
                              },
                            ),
                            SizedBox(height: 5),
                            GestureDetector(
                              child: Container(
                                height: 50,
                                width: width,
                                decoration: BoxDecoration(
                                  color: containerColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 12.0),
                                        child: Icon(LucideIcons.library),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          "User Guidelines",
                                          style:
                                              GoogleFonts.poppins(fontSize: 18),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  myRoute(
                                    Userguidelines(),
                                  ),
                                );
                                HapticFeedback.heavyImpact();
                                setState(() {
                                  present = !present;
                                });
                              },
                            ),
                            SizedBox(height: 5),
                            GestureDetector(
                              child: Container(
                                height: 50,
                                width: width,
                                decoration: BoxDecoration(
                                  color: containerColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 12.0),
                                        child: Icon(LucideIcons.info),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          "Help",
                                          style:
                                              GoogleFonts.poppins(fontSize: 18),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  myRoute(
                                    Help(),
                                  ),
                                );
                                HapticFeedback.heavyImpact();
                              },
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            GestureDetector(
                              child: Container(
                                height: 50,
                                width: width,
                                decoration: BoxDecoration(
                                  color: containerColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 12.0),
                                        child: Icon(LucideIcons.users2),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          "Room Mates",
                                          style:
                                              GoogleFonts.poppins(fontSize: 18),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              onTap: () {
                                HapticFeedback.heavyImpact();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> saveLoginState(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }

  Future<void> _saveProfileImage(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile', name);
  }

  Future<void> _loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    name = prefs.getString('profile') ?? "profile";
  }

  bool isStudentInsideHostel(Position studentPosition) {
    double distance = Geolocator.distanceBetween(
      studentPosition.latitude,
      studentPosition.longitude,
      hostel!['latitude'],
      hostel!['longitude'],
    );

    return distance <= allowedRadius;
  }

  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("⚠ Location services are disabled.");
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("❌ Location permission denied.");
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("⚠ Location permission permanently denied. Enable from settings.");
      return null;
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  Future<void> updateStudentStatus() async {
    if (isloading) return; // Prevent multiple taps
    setState(() => isloading = true); // Start loading
    _showSnackBar("please wait ..updating..");

    Position? studentPosition = await getCurrentLocation();
    if (studentPosition == null) {
      setState(() => isloading = false);
      return;
    }

    bool insideHostel = isStudentInsideHostel(studentPosition);
    if (_animationController.isAnimating) {
      setState(() => isloading = false);
      return;
    }
    print("present:$present");
    if (present && !insideHostel) {
      print("❌ You must be inside the hostel to mark 'IN'.");
      return; //return false;
    } else if (!present) {
      _showSnackBar("Return back safely");
      // && insideHostel
      //print("❌ You must be outside the hostel to mark 'OUT'.");
      _animationController.forward().then((_) {
        update(present);
        setState(() {
          present = !present; // Flip the state
        });
      });
    } else {
      _showSnackBar("Status updated to present..Welcome Back");
      _animationController.reverse().then((_) {
        update(present);
        setState(() {
          present = !present; // Flip the state
        });
      });
      // Save status in Firestore or local database
    }
    setState(() => isloading = false);
  }

  void update(bool p) {
    User? user = FirebaseAuth.instance.currentUser;
    try {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({'present': p});
    } catch (e) {
      print("errors:$e");
    }
  }

  void updateP(String profile) {
    User? user = FirebaseAuth.instance.currentUser;
    try {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({'dp': profile});
    } catch (e) {
      print("errors:$e");
    }
  }
  /*void _toggleFlip() {
    Future.delayed(Duration(milliseconds: 250), () {
      setState(() {
        present = !present; // Switch content at halfway point
      });
    });
  }*/

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    Mysnackbar.show(context, message, isError: isError);
  }
}
