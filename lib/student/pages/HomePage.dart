import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:minipro/Theme/appcolors.dart';
import 'package:minipro/Theme/fonts.dart';
import 'package:minipro/student/components/custom_route.dart';
import 'package:minipro/student/components/myContainer.dart';
import 'package:minipro/student/pages/home/complaint/complaint.dart';
import 'package:minipro/student/pages/home/maintenance/maintenance.dart';
import 'package:minipro/student/pages/home/leaveApplication.dart';
import 'package:minipro/student/pages/home/payment.dart';
import 'package:minipro/student/pages/home/vacate/vacate.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    LinearGradient containerGradient = AppColors.getcontainerGradient(context);
    //double height = MediaQuery.of(context).size.height;
    double cheight = 65;
    String wish;

    var morning = [
      "Good morning! Shine bright today!",
      "Rise and shine, it’s a brand new day!",
      "Make today amazing!",
      "Good morning! Let’s do this!",
      "Start your day with a smile!",
    ];
    var evening = [
      "Good evening! Relax and unwind.",
      "Evening vibes only.",
      "Enjoy your peaceful evening.",
      "Let go of the day, relax.",
      "Good evening! Rest up for tomorrow.",
    ];
    var night = [
      "Good night, sweet dreams!",
      "Sleep tight, see you tomorrow!",
      "Good night! Rest well.",
      "Sweet dreams, sleep tight!",
      "Good night, wake up refreshed!",
    ];
    DateTime now = DateTime.now();
    int hour = now.hour;
    if (hour > 4 && hour <= 12) {
      wish = morning[generateRandomNumber()];
    } else if (hour > 12 && hour <= 19) {
      wish = evening[generateRandomNumber()];
    } else {
      wish = night[generateRandomNumber()];
    }
    //double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "DASHBOARD",
          style: GoogleFonts.nunito(
              textStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        automaticallyImplyLeading: false,
      ),
      body: ScrollConfiguration(
        behavior: NoGlowScrollBehavior(),
        child: ListView(
          padding: EdgeInsets.all(8),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 30, top: 20),
              child: Text(
                wish,
                style: GoogleFonts.nunito(
                  textStyle:
                      TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context, myRoute(Maintenance()));
              },
              child: Mycontainer(
                height: cheight,
                gradient: containerGradient,
                child: Row(
                  children: [
                    Icon(Ionicons.construct_outline),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        "Maintenance Request",
                        style: AppFonts.body,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context, myRoute(Leaveapplication()));
              },
              child: Mycontainer(
                gradient: containerGradient,
                height: cheight,
                child: Row(
                  children: [
                    Icon(Ionicons.calendar_outline),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        "Leave Application",
                        style: AppFonts.body,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context, myRoute(Payment()));
              },
              child: Mycontainer(
                height: cheight,
                gradient: containerGradient,
                child: Row(
                  children: [
                    Icon(Ionicons.card_outline),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        "Payment",
                        style: AppFonts.body,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              child: Mycontainer(
                height: cheight,
                gradient: containerGradient,
                child: Row(
                  children: [
                    Icon(Ionicons.flag_outline),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        "Complaint registration",
                        style: AppFonts.body,
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {
                Navigator.push(context, myRoute(Complaint()));
              },
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context, myRoute(Vacate()));
              },
              child: Mycontainer(
                height: cheight,
                gradient: containerGradient,
                child: Row(
                  children: [
                    Icon(Icons.luggage),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        "Vacate",
                        style: AppFonts.body,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  int generateRandomNumber() {
    Random random = Random();
    int randomNumber = random.nextInt(5);
    return randomNumber;
  }
}

class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
