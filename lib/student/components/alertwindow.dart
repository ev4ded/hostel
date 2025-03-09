import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minipro/Theme/appcolors.dart';
import 'package:minipro/student/menucolor.dart';
import 'package:provider/provider.dart';

void showPendingDialog(BuildContext context) {
  Color buttonColor = AppColors.buttonColor;
  Color buttonText = AppColors.buttonTextColor;
  int count = 0;
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return PopScope(
        canPop: false,
        child: Stack(
          children: [
            BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: Container(
                  color: Colors.black.withAlpha(10),
                )),
            Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
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
                      "Request status",
                      style: GoogleFonts.inter(fontSize: 20),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Your request is being processed.",
                      style: GoogleFonts.inter(),
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(buttonColor),
                        ),
                        onPressed: () {
                          Navigator.popUntil(context, (route) {
                            return count++ >= 2;
                          });
                        },
                        child: Text(
                          "OK",
                          style: GoogleFonts.inter(
                              color: buttonText, fontWeight: FontWeight.w600),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

void showResolvedDialog(BuildContext context, String status) {
  Color buttonColor = AppColors.buttonColor;
  Color buttonText = AppColors.buttonTextColor;
  int count = 0;
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return PopScope(
        canPop: false,
        child: Stack(
          children: [
            BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: Container(
                  color: Colors.black.withAlpha(10),
                )),
            Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
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
                      "Request status",
                      style: GoogleFonts.inter(fontSize: 20),
                    ),
                    SizedBox(height: 20),
                    Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          softWrap: true,
                          "Your latest request has been $status.",
                          style: GoogleFonts.inter(),
                        )),
                    SizedBox(height: 5),
                    Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.popUntil(context, (route) {
                                  return count++ >= 2;
                                });
                              },
                              child: Text(
                                "cancel",
                                style: GoogleFonts.inter(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStatePropertyAll(buttonColor),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  "Apply again",
                                  style: GoogleFonts.inter(
                                      color: buttonText,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ))
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
