import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:minipro/authentication/fcmtoken.dart';
import 'package:minipro/firebase/firestore_services.dart';
import 'package:minipro/authentication/loginpage.dart';
import 'package:minipro/Theme/appcolors.dart';
import 'package:minipro/student/components/custom_route.dart';
import 'package:minipro/student/components/customProfilepopUp.dart';
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

class _ProfileState extends State<Profile> {
  final FirestoreServices _firestoreService = FirestoreServices();
  Map<String, dynamic>? userData;
  Color flipC = Color.fromRGBO(237, 208, 176, 1);
  bool present = true;
  String name = "profile";
  @override
  void initState() {
    super.initState();
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
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    Color containerColor = AppColors.getContainerColor(context);
    Color detailsC = AppColors.buttonColor;
    Color buttonTextC = AppColors.buttonTextColor;
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
                                    }
                                  },
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundColor:
                                        Color.fromRGBO(93, 101, 95, 1),
                                    key: ValueKey(name),
                                    backgroundImage: name.isNotEmpty
                                        ? Image.asset(
                                                "assets/images/profile/$name.png")
                                            .image
                                        : Image.asset(
                                                "assets/images/profile/profile.png")
                                            .image,
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
                                                userData!["college"] ??
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
                              onTap: () {
                                setState(() {
                                  present = !present;
                                });
                              },
                              child: Container(
                                height: 150,
                                width: 150,
                                decoration: BoxDecoration(
                                  color: flipC,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: (present)
                                      ? Image(
                                          image: Image.asset(
                                                  "assets/images/cutepng.png",
                                                  fit: BoxFit.contain)
                                              .image)
                                      : Image(
                                          image: Image.asset(
                                                  "assets/images/dead.png",
                                                  fit: BoxFit.contain)
                                              .image),
                                ),
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
}
