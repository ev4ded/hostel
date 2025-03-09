import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minipro/Theme/appcolors.dart';
import 'package:minipro/student/menucolor.dart';
import 'package:provider/provider.dart';

void showMenuColorChange(BuildContext context) {
  Map<int, List<Color>> themeColors = {
    0: [
      Color.fromRGBO(213, 185, 145, 1),
      Color.fromRGBO(224, 199, 174, 1),
      Color.fromRGBO(255, 189, 109, 1),
      Color.fromRGBO(120, 47, 32, 1),
    ],
    1: [
      Color.fromRGBO(255, 189, 109, 1),
      Color.fromRGBO(114, 47, 55, 1),
      Color.fromRGBO(239, 223, 187, 1),
      Color.fromRGBO(70, 30, 35, 1),
    ],
    2: [
      Color.fromRGBO(200, 200, 255, 1),
      Color.fromRGBO(60, 90, 180, 1),
      Color.fromRGBO(180, 200, 230, 1),
      Color.fromRGBO(255, 255, 255, 1),
    ]
  };
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      return Consumer<Menucolor>(
        // ✅ Use Consumer instead
        builder: (context, menucolor, child) {
          return Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: Container(color: Colors.black.withAlpha(10)),
              ),
              Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                backgroundColor: AppColors.getAlertWindowC(context),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Select a theme",
                        style: GoogleFonts.inter(fontSize: 18),
                      ),
                      SizedBox(height: 5),
                      Text("Tap on a theme set to apply",
                          style: GoogleFonts.inter()),
                      SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(themeColors.length, (index) {
                          return GestureDetector(
                            onTap: () {
                              menucolor
                                  .setTheme(index); // ✅ Safe provider access
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: AppColors.hintColor,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(4, (i) {
                                    return Container(
                                      height: 40,
                                      width: 40,
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 5),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: themeColors[index]![i],
                                        border: Border.all(
                                          color:
                                              AppColors.getTextColor(context),
                                          width: 1.5,
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.inter(
                                color: Colors.red, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
