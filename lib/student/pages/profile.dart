import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:minipro/Admin/adminqueries.dart';
import 'package:minipro/firebase/firestore_services.dart';
import 'package:minipro/Theme/appcolors.dart';
import 'package:minipro/student/Student_queries/queries.dart';
import 'package:minipro/student/components/alertwindow.dart';
import 'package:minipro/student/components/badges.dart';
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
  List<dynamic> collectBadges = ["student"];
  List<Map<String, String>>? roommates;
  static const double allowedRadius = 500;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool isloading = false;
  bool isDataReady = false;
  String? badgeText;
  LinearGradient? badgeGradient;
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: pi).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    fetchUserData();
    listenToUserUpdates();
    loadCachedThenRefresh();
  }

  void loadCachedThenRefresh() async {
    // 🔹 Step 1: Load from cache instantly
    Map<String, dynamic>? cachedUserData =
        await _firestoreService.getCachedUserData();
    if (cachedUserData != null) {
      setState(() {
        userData = cachedUserData;
        name = userData!["dp"];
        collectBadges = userData!['badges'];
        badgeText = userData!['badgeName'];
        badgeGradient = getbadgesColor(badgeText!);
        present = userData!['present'];
        isDataReady = true; // ✅ show instantly
      });
    }

    // 🔹 Step 2: Refresh in the background (optional: delay for smoothness)
    await _firestoreService.getUserData(); // fetches fresh & updates cache
    Map<String, dynamic>? updatedUserData =
        await _firestoreService.getCachedUserData();
    if (updatedUserData != null) {
      setState(() {
        userData = updatedUserData;
        name = userData!["dp"];
        collectBadges = userData!['badges'];
        badgeText = userData!['badgeName'];
        badgeGradient = getbadgesColor(badgeText!);
        present = userData!['present'];
      });
    }
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
    List<Map<String, String>>? myMates =
        await getRoomates(userData!['hostelId'], userData!['room_no']);
    setState(() {
      present = userData!['present'] ?? true;
      name = userData!["dp"] ?? "profile";
      collectBadges = userData!['badges'] ?? ["student"];
      badgeText = userData!['badgeName'] ?? "Student";
      badgeGradient = getbadgesColor(badgeText!);
      roommates = myMates;
      isDataReady = true;
    });
    Map<String, dynamic>? temp = await getHostelDetails(userData!["hostelId"]);
    if (temp != null) {
      hostel = temp;
    }
    //print("present::$present");
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    LinearGradient containerColor = AppColors.getcontainerGradient(context);
    Color detailsC = AppColors.buttonColor;
    return Scaffold(
      body: !isDataReady
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
                                          color: AppColors.buttonColor,
                                          width: 2), // Border color & width
                                    ),
                                    child: CircleAvatar(
                                      radius: 55,
                                      backgroundColor:
                                          Color.fromRGBO(93, 101, 95, 1),
                                      key: ValueKey(name),
                                      backgroundImage: name.isNotEmpty
                                          ? Image.asset(
                                                  "assets/images/profile/$name.jpg")
                                              .image
                                          : Image.asset(
                                                  "assets/images/profile/1.jpg")
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
                                        // badge
                                        GestureDetector(
                                          onTap: () async {
                                            String? selectedBadge = await badge(
                                                context, collectBadges);
                                            if (selectedBadge != null) {
                                              saveBadge(
                                                  selectedBadge); //selectedBadge['gradient']
                                              setState(() {
                                                badgeText = selectedBadge;
                                                badgeGradient = getbadgesColor(
                                                    selectedBadge);
                                              });
                                            }
                                          },
                                          child: Container(
                                            height: 38,
                                            width: 110,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              gradient: badgeGradient ??
                                                  LinearGradient(colors: [
                                                    Color(0xFFFF7E5F),
                                                    Color(0xFFFFB88C)
                                                  ]),
                                            ),
                                            child: Center(
                                              child: Text(
                                                (badgeText) ??
                                                    userData![
                                                        "role"], // Safely handle null
                                                style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                        ),
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
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600),
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
                              onTap: () {
                                updateStudentStatus();
                              },
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
                                            ? Colors.white
                                            : Color.fromRGBO(197, 168, 136, 1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      //attendace part
                                      child: (isloading)
                                          ? Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            )
                                          : (present)
                                              ? Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      width: 5,
                                                      color: Color.fromRGBO(
                                                          197, 168, 136, 1),
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Expanded(
                                                        flex: 1,
                                                        child: Image.asset(
                                                          "assets/images/cutepng.png",
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                      Text(
                                                        "INSIDE",
                                                        style:
                                                            GoogleFonts.inter(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 12),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              : Container(
                                                  decoration: BoxDecoration(
                                                    color: Color.fromRGBO(
                                                        197, 168, 136, 1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
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
                                  gradient: containerColor,
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
                                    Studenteditprofile(),
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
                                  gradient: containerColor,
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
                                  gradient: containerColor,
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
                                          "Change password?",
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
                                  gradient: containerColor,
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
                                  gradient: containerColor,
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
                                  gradient: containerColor,
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
                                //print("room mates:$roommates");
                                getroommates(context, roommates);
                                HapticFeedback.heavyImpact();
                              },
                            ),
                            SizedBox(height: 5),
                            GestureDetector(
                              child: Container(
                                height: 50,
                                width: width,
                                decoration: BoxDecoration(
                                  gradient: containerColor,
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
                                signout(context);
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
      _showSnackBar("cant access your location", isError: true);
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar("Location permission denied.", isError: true);
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar(
          "Location permission permanently denied. Enable from settings.",
          isError: true);
      return null;
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  Future<void> updateStudentStatus() async {
    if (isloading) return; // Prevent multiple taps
    setState(() => isloading = true); // Start loading
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
    if (!present && !insideHostel) {
      _showSnackBar("You must be inside the hostel to mark 'PRESENT'",
          isError: true);
      setState(() {
        isloading = false;
      });
      return; //return false;
    } else if (present) {
      _showCelebrate("Return safely, ", "see you soon!");
      // && insideHostel
      //print("❌ You must be outside the hostel to mark 'OUT'.");
      _animationController.forward().then((_) {
        update(present);
      });
      setState(() {
        present = !present; // Flip the state
      });
    } else {
      _showCelebrate("Welcome back! You're now ", "checked in.");
      _animationController.reverse().then((_) {
        update(present);
      });
      setState(() {
        present = !present; // Flip the state
      });
      // Save status in Firestore or local database
    }
    setState(() => isloading = false);
  }

  void update(bool p) async {
    User? user = FirebaseAuth.instance.currentUser;
    try {
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(user!.uid);
      final attendanceDoc = userDoc
          .collection('attendance')
          .doc(DateFormat('yyyy-MM-dd').format(DateTime.now()));
      await userDoc.update({'present': p});
      final snapshot = await attendanceDoc.get();
      if (snapshot.exists) {
        await attendanceDoc.update({
          'month': DateTime.now().month,
          'present': p,
          p ? 'markedIN' : 'markedOUT':
              DateFormat('HH:mm').format(DateTime.now()),
        });
      } else {
        await attendanceDoc.set({
          'month': DateTime.now().month,
          'present': p,
          p ? 'markedIN' : 'markedOUT':
              DateFormat('HH:mm').format(DateTime.now()),
        });
      }
    } catch (e) {
      print("Error: $e");
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    Mysnackbar.show(context, message, isError: isError);
  }

  void _showCelebrate(String message, special) {
    if (!mounted) return;
    Mysnackbar.celebrate(context, message, special);
  }

  void saveBadge(String name) {
    // LinearGradient color
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'badgeName': name,
        //'badgeGradient': grad,
      });
    }
  }
}
