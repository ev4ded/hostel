import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class Help extends StatefulWidget {
  const Help({super.key});

  @override
  State<Help> createState() => _HelpState();
}

class _HelpState extends State<Help> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(LucideIcons.chevronLeft),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              "Contact Support",
              style:
                  GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16),
              child: Text(
                "Welcome to the Help Page! If you encounter any issues while using the app, refer to the sections below for guidance. If you need further assistance, contact support via the in-app help desk.",
                softWrap: true,
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: 15),
            Container(
              height: 1,
              color: Colors.white,
              width: MediaQuery.of(context).size.width * 0.75,
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16),
              child: Text(
                "If you are facing any kind of issue, you can reach out to the support team:",
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    "Email:",
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    " support@hostelapp.com",
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    "Phone:",
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    "+91 85904 93280",
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w300),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16),
              child: Text(
                "Thank you for using the Hostel Management App! We’re here to assist you.",
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w300),
              ),
            ),
            Text(""),
          ],
        ),
      ),
    );
  }
}
