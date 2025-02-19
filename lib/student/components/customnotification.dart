import 'package:flutter/material.dart';

void customPopup(BuildContext context, String content, Function function) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 300, // Small size
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
              onPressed: () {
                function();
              },
              child: Text("OK"),
            ),
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
        height: height * 0.45, // Slightly adjusted for better spacing
        //: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
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
                  profileOption(context, "anagha"),
                  profileOption(context, "anand"),
                  profileOption(context, "ann"),
                ],
              ),
              SizedBox(height: 10),
              // Second Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  profileOption(context, "arun"),
                  profileOption(context, "azhar"),
                  profileOption(context, "cecil"),
                ],
              ),
              SizedBox(height: 10),
              // Third Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  profileOption(context, "sanjay"), // Fixed incorrect names
                  profileOption(context, "shervi"), // Fixed incorrect names
                  profileOption(context, "aravind"),
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
        radius: 43,
        backgroundImage: AssetImage("assets/images/profile/$imageName.png"),
      ),
    ),
    onTap: () {
      Navigator.pop(context, imageName); // Return the selected name
    },
  );
}
