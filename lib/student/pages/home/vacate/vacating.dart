import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:minipro/Theme/appcolors.dart';
import 'package:minipro/splashscreen.dart';
import 'package:minipro/student/components/custom_route.dart';
import 'package:minipro/student/components/custompainter.dart';
import 'package:minipro/student/pages/home/vacate/pay.dart';

class Vacating extends StatefulWidget {
  const Vacating({super.key});

  @override
  State<Vacating> createState() => _VacatingState();
}

class _VacatingState extends State<Vacating> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double heigth = MediaQuery.of(context).size.height * 0.5;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color(0xFF2B2D42), // deep space blue
                    Color(0xFF8D99AE), // steel gray
                    Color(0xFFEDF2F4), // moon dust
                  ],
                ),
              ),
              width: width,
              height: heigth,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size(width, heigth),
                    painter: Custompainter(),
                  ),
                  SizedBox(
                    width: width,
                    height: width * 0.5833,
                    child: Center(
                      child: Image.asset("assets/images/vacating.png"),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Your vacting request in currently being processed..",
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: GoogleFonts.inter(),
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          WidgetStatePropertyAll(AppColors.buttonColor)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      myRoute(Pay()),
                    );
                  },
                  child: Text(
                    "pay",
                    style: GoogleFonts.inter(
                        color: AppColors.buttonTextColor,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                        context, myRoute(Splashscreen()), (route) => false);
                  },
                  icon: Icon(LucideIcons.rotateCcw),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
