import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:minipro/Admin/adminqueries.dart';
import 'package:minipro/Admin/profile.dart';
import 'package:minipro/Theme/appcolors.dart';
import 'package:minipro/authentication/fcmtoken.dart';
import 'package:minipro/authentication/loginpage.dart';
import 'package:minipro/student/components/customProfilepopUp.dart';
import 'package:minipro/student/components/custom_route.dart';
import 'package:minipro/student/pages/profile/changepassword.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Wardenlisting extends StatefulWidget {
  const Wardenlisting({super.key});

  @override
  State<Wardenlisting> createState() => _WardenlistingState();
}

class _WardenlistingState extends State<Wardenlisting>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Color mainColor = Colors.blueAccent;
  String hostelID = '123';
  int? expandedIndex;
  List<Map<String, dynamic>>? wardens;
  bool isloading = true;

  @override
  void initState() {
    super.initState();
    getWardenDetails();
    _tabController = TabController(length: 2, vsync: this);
  }

  void getWardenDetails() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    String? id = await fetchAdminHostelId(uid);
    if (id != null) {
      setState(() {
        hostelID = id;
      });
      List<Map<String, dynamic>>? fetchedWardens = await getWardens(hostelID);
      setState(() {
        wardens = fetchedWardens;
        isloading = false;
      });
      print(wardens);
    } else {
      setState(() {
        isloading = false; // Prevent infinite loading if `id` is null
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Color containerColor = AppColors.getContainerColor(context);
    Color tileColor = AppColors.getContainerColor(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "heyy..Welcome back!!!",
          style: GoogleFonts.poppins(
              fontSize: 22, color: AppColors.getTextColor(context)),
        ),
        actions: [
          IconButton(
              onPressed: () {
                profile(context);
              },
              icon: Icon(
                LucideIcons.userCircle2,
                color: Colors.blueGrey,
                size: 35,
              ))
        ],
        backgroundColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Align(
            alignment: Alignment.center, // Centering the TabBar
            child: TabBar(
              labelStyle: GoogleFonts.poppins(),
              controller: _tabController,
              labelColor: mainColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: mainColor,
              tabs: [
                Tab(
                  text: "Warden Listing",
                ),
                Tab(text: "Warden Approval"),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          StreamBuilder<List<QueryDocumentSnapshot>>(
            stream: ListingWarden(hostelID),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text("Error:${snapshot.error}"),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text("There are no wardens in your hostel"),
                );
              }
              List<QueryDocumentSnapshot> list = snapshot.data!;
              return SingleChildScrollView(
                child: SizedBox(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      var warden = list[index].data() as Map<String, dynamic>;
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(15),
                                color: tileColor,
                              ),
                              height: 75,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFF8C291),
                                      ),
                                      child: Center(
                                        child: Text(
                                          warden['Name']
                                              .toString()[0]
                                              .toUpperCase(),
                                          style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Text(
                                        warden['Name'] ?? "Not found",
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    Spacer(),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          expandedIndex =
                                              (expandedIndex == index)
                                                  ? null
                                                  : index;
                                        });
                                      },
                                      icon: Icon(LucideIcons.chevronDown),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (expandedIndex == index)
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(10),
                                color: AppColors.getTileColorLight(context),
                              ),
                              width: MediaQuery.of(context).size.width * 0.9,
                              padding: EdgeInsets.all(8),
                              child: (isloading)
                                  ? Center(child: CircularProgressIndicator())
                                  : Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          buildInfoRow("Designation:",
                                              "${wardens![index]['designation'] ?? ""}"),
                                          buildInfoRow("Gender:",
                                              "${wardens![index]['gender'] ?? ""}"),
                                          buildInfoRow("Phone Number:",
                                              "${wardens![index]['phone_no'] ?? ""}"),
                                          buildInfoRow("Email:",
                                              "${wardens![index]['email'] ?? ""}"),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                customPopup(
                                                  context,
                                                  "Are you sure you want to remove \n${wardens![index]['username']}?",
                                                  () {
                                                    deleteWarden(
                                                        wardens![index]
                                                            ['docId'],
                                                        wardens![index]
                                                            ['hostelId']);
                                                  },
                                                );
                                              },
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    WidgetStatePropertyAll(
                                                        Colors.red),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(LucideIcons.trash2),
                                                  SizedBox(width: 2),
                                                  Text("Remove")
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          ),
          StreamBuilder<List<QueryDocumentSnapshot>>(
            stream: WardenApproval(hostelID),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text("Error:${snapshot.error}"),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text("No new recruitments.."),
                );
              }
              List<QueryDocumentSnapshot> list = snapshot.data!;
              return SingleChildScrollView(
                child: SizedBox(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      var warden = list[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(15),
                            color: tileColor,
                          ),
                          height: 75,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFF8C291),
                                  ),
                                  child: Center(
                                    child: Text(
                                      warden['username']
                                          .toString()[0]
                                          .toUpperCase(),
                                      style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Text(
                                    warden['username'] ?? "Not found",
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Spacer(),
                                IconButton(
                                  onPressed: () async {
                                    await verifyWarden(warden.id, warden);
                                  },
                                  icon: Icon(
                                    LucideIcons.checkCircle2,
                                    color: Colors.green,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    LucideIcons.xCircle,
                                    color: Colors.red,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void profile(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: Container(
                  color: Colors.black.withAlpha(10),
                ),
              ),
              Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: AppColors.getAlertWindowC(context),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding:
                      EdgeInsets.only(top: 8, bottom: 15, left: 8, right: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    //mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Select an option",
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              LucideIcons.xCircle,
                              color: Colors.red,
                              size: 25,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            myRoute(AdminProfile()),
                          );
                        },
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.getContainerColor(context),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Profile",
                                  style: GoogleFonts.poppins(),
                                ),
                                Icon(LucideIcons.chevronRight),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      GestureDetector(
                        onTap: () {
                          customPopup(
                            context,
                            "Are you sure to sign out?",
                            () {
                              FirebaseAuth.instance.signOut();
                              saveLoginState(false);
                              User? userid = FirebaseAuth.instance.currentUser;
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
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.getContainerColor(context),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Sign out",
                                  style: GoogleFonts.poppins(),
                                ),
                                Icon(LucideIcons.chevronRight),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            myRoute(
                              Changepassword(),
                            ),
                          );
                        },
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.getContainerColor(context),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Change password",
                                  style: GoogleFonts.poppins(),
                                ),
                                Icon(LucideIcons.chevronRight),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        });
  }

  Future<void> saveLoginState(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }

  Future<void> verifyWarden(
      String uid, QueryDocumentSnapshot<Object?> user) async {
    try {
      await FirebaseFirestore.instance
          .collection("hostels")
          .doc(hostelID)
          .collection("warden")
          .doc(uid)
          .set({
        'Name': user['username'],
      });
      await FirebaseFirestore.instance.collection("users").doc(uid).update({
        'isApproved': true,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "$label ",
              style:
                  GoogleFonts.poppins(color: AppColors.getTextColor(context)),
            ),
            TextSpan(
              text: value,
              style: GoogleFonts.poppins(
                color: AppColors.getTextColor(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
