import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minipro/Admin/profile.dart';
import 'package:minipro/student/components/custom_route.dart';
import 'package:minipro/student/pages/profile/editprofile.dart';
import 'package:minipro/warden/pages/functions/editprofile.dart';

class Boardingpage extends StatefulWidget {
  final String? role;
  const Boardingpage({super.key, this.role});

  @override
  // ignore: library_private_types_in_public_api
  _BoardingpageState createState() => _BoardingpageState();
}

class _BoardingpageState extends State<Boardingpage> {
  Widget page = Studenteditprofile();
  @override
  void initState() {
    super.initState();
    setpage();
  }

  void setpage() {
    if (widget.role == 'warden') {
      page = EditWardenProfile();
    } else if (widget.role == 'admin') {
      page = AdminProfile();
    } else {
      page = Studenteditprofile();
    }
  }

  final PageController _pageController = PageController();
  int _currentPage = 0;
  List<Map<String, String>> onboardingData = [
    {
      "image": "assets/images/welcome.png",
      "title": "Effortless Hostel Management",
      "description":
          "Manage your hostel life with ease. Stay updated and organized!"
    },
    {
      "image": "assets/images/student.png",
      "title": "Your Hostel, Your Control",
      "description":
          "Apply for leave, report maintenance, and track payments seamlessly."
    },
    {
      "image": "assets/images/star.png",
      "title": "Unlock Your Achievements!!",
      "description":
          "Collect badges, flex your wins, and make your mark in the hostel!."
    },
    {
      "image": "assets/images/joinus.png",
      "title": "Join Us Today!",
      "description": "Log in now and experience a smarter hostel life!"
    },
    {
      "image": "assets/images/edit.png",
      "title": "Complete Your Profile!",
      "description":
          "Update your details to access all hostel features seamlessly."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4A4A4A), // Dark theme
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: onboardingData.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return AnimatedOpacity(
                  duration: Duration(milliseconds: 500),
                  opacity: _currentPage == index ? 1.0 : 0.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        onboardingData[index]["image"]!,
                        height: 250, // Adjust as needed
                        width: 250,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 20),
                      Text(
                        onboardingData[index]["title"]!,
                        style: GoogleFonts.nunito(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.amberAccent,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          onboardingData[index]["description"]!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.raleway(
                              fontSize: 16, color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Page Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              onboardingData.length,
              (index) => buildDot(index, context),
            ),
          ),
          SizedBox(height: 20),
          // Next Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amberAccent,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                if (_currentPage < onboardingData.length - 1) {
                  _pageController.nextPage(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                } else {
                  User? user = FirebaseAuth.instance.currentUser;
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(user!.uid)
                      .update({
                    'boardingPage': true,
                  });
                  FirebaseFirestore.instance
                      .collection('points')
                      .doc(user.uid)
                      .set({
                    'complaint': 0,
                    'leave': 0,
                    'maintenance': 0,
                    'score': 0
                  });
                  Navigator.pushReplacement(
                      context, myRoute(page)); // Replace with your login page
                }
              },
              child: Text(
                _currentPage == onboardingData.length - 1 ? "Edit Now" : "Next",
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  // Page indicator dot
  Widget buildDot(int index, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 5),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.amberAccent : Colors.white24,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
