import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class Userguidelines extends StatefulWidget {
  const Userguidelines({super.key});

  @override
  State<Userguidelines> createState() => _UserguidelinesState();
}

class _UserguidelinesState extends State<Userguidelines> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Guidelines",
          style: GoogleFonts.inter(),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(LucideIcons.chevronLeft)),
      ),
      body: Center(
        child: Center(
          child: Container(
            padding:EdgeInsets.only(
                    top: 8.0, bottom: 8, left: 8, right: 8),
            height: height * 0.85,
            width: width * 0.95,
            decoration: BoxDecoration(
                color: Colors.grey, borderRadius: BorderRadius.circular(15)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 8.0, bottom: 8, left: 8, right: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "1. Introduction",
                      style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    Text(
                      "Welcome to the Hostel Management App! This app is designed to streamline hostel-related processes for both students and the warden. Please read these guidelines carefully to ensure a smooth experience.",
                      softWrap: true,
                      style: GoogleFonts.lato(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "2. General Guidelines",
                      style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Ensure all personal details are accurate and up-to-date.\nUse appropriate language and behavior while communicating via the app.\nRegularly check notifications for important updates and approvals.\nAdhere to hostel rules and policies as outlined by the administration.",
                      softWrap: true,
                      style: GoogleFonts.lato(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "3. Features Usage Guidelines",
                      style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    Text(
                      "  a. Maintenance Requests ",
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Clearly specify the issue and attach necessary details or images.\nTrack request status via the app",
                      softWrap: true,
                      style: GoogleFonts.lato(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "  b. Leave Application",
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Apply for leave with valid reasons and supporting documents (if required).\nCheck approval status before planning your leave.",
                      softWrap: true,
                      style: GoogleFonts.lato(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "  c. Payments",
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Use the integrated payment system for hostel-related payments.\nVerify transaction details before proceeding.",
                      softWrap: true,
                      style: GoogleFonts.lato(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "  d. Complaints",
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Report genuine complaints only.\nAvoid misuse of the complaint system",
                      softWrap: true,
                      style: GoogleFonts.lato(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "  e. Notices & Updates",
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Stay updated with the latest hostel notifications.\nFollow instructions provided in official notices.",
                      softWrap: true,
                      style: GoogleFonts.lato(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "4. Security & Privacy",
                      style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Keep login credentials confidential.\nDo not share sensitive hostel-related information with unauthorized individuals.\nReport any suspicious activity or security concerns to the hostel administration.",
                      softWrap: true,
                      style: GoogleFonts.lato(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "5. Technical Support",
                      style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "For technical issues, contact the app support team through the designated help section.\nEnsure the app is updated to the latest version for the best experience.",
                      softWrap: true,
                      style: GoogleFonts.lato(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "6. Compliance & Penalties",
                      style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Violation of app policies may result in restricted access or disciplinary action.\nMisuse of features such as complaints, leave applications, or payments will be taken seriously.",
                      softWrap: true,
                      style: GoogleFonts.lato(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "7. Contact & Help Desk",
                      style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "For any queries or assistance, please reach out to the hostel office or use the in-app support feature.",
                      softWrap: true,
                      style: GoogleFonts.lato(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    Text(
                      "Thank you for using the Hostel Management App responsibly!",
                      softWrap: true,
                      style: GoogleFonts.lato(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(184, 134, 11, 1)),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
