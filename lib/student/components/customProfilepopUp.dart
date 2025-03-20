import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minipro/Theme/appcolors.dart';

void customPopup(BuildContext context, String content, Function function) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        //width: 20, // Small size
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /*("Small Window",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),*/
            SizedBox(height: 10),
            Text(content),
            SizedBox(height: 20),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      WidgetStatePropertyAll(AppColors.buttonColor)),
              onPressed: () {
                function();
              },
              child: Text(
                "YES",
                style: GoogleFonts.inter(
                    color: AppColors.buttonTextColor,
                    fontWeight: FontWeight.w600),
              ),
            )
          ],
        ),
      ),
    ),
  );
}

Future<String?> customImageSuggest(BuildContext context) async {
  double height = MediaQuery.of(context).size.height;
  double width = MediaQuery.of(context).size.width;

  return await showDialog<String>(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: width,
        height: height * 0.5, // Slightly adjusted for better spacing
        //: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Select Profile Image",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              // First Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  profileOption(context, "1"),
                  profileOption(context, "2"),
                  profileOption(context, "3"),
                ],
              ),
              SizedBox(height: 10),
              // Second Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  profileOption(context, "4"),
                  profileOption(context, "5"),
                  profileOption(context, "6"),
                ],
              ),
              SizedBox(height: 10),
              // Third Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  profileOption(context, "7"), // Fixed incorrect names
                  profileOption(context, "8"), // Fixed incorrect names
                  profileOption(context, "9"),
                ],
              ),
              SizedBox(height: 10),
              // Third Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  profileOption(context, "10"), // Fixed incorrect names
                  profileOption(context, "11"), // Fixed incorrect names
                  profileOption(context, "12"),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget profileOption(BuildContext context, String imageName) {
  return GestureDetector(
    child: Padding(
      padding: EdgeInsets.only(left: 5),
      child: CircleAvatar(
        radius: 40,
        backgroundImage: AssetImage("assets/images/profile/$imageName.jpg"),
      ),
    ),
    onTap: () {
      Navigator.pop(context, imageName); // Return the selected name
    },
  );
}
