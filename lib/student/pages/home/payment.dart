import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:minipro/Theme/appcolors.dart';
import 'package:minipro/firebase/firestore_services.dart';
import 'package:minipro/student/components/mytextfield.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class Payment extends StatefulWidget {
  const Payment({super.key});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  final String upiId = "aravindap501@okaxis"; // Replace with your UPI ID
  final String name = "Hostel Management";
  final String amount = "501";
  Color buttonColor = AppColors.buttonColor;
  Color buttonTextColor =
      AppColors.buttonTextColor; //overflows when name is too large
  final FirestoreServices _firestoreService = FirestoreServices();
  final transcationID = TextEditingController();
  Map<String, dynamic>? userData;
  bool isloading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    Map<String, dynamic>? userDetails =
        await _firestoreService.getUserDetails();
    setState(() {
      userData = userDetails;
      isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(),
      body: (isloading)
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.only(
                  left: 20.0, right: 20, top: 40, bottom: 40),
              child: Center(
                child: Container(
                  width: width * 0.9,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(245, 240, 225, 1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, bottom: 8, left: 12, right: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Center(
                            child: Text(
                              "Bill for ${DateFormat('MMMM').format(DateTime.now()).toUpperCase()} month",
                              style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                  letterSpacing: 2),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Center(
                            child: Container(
                              color: Colors.black,
                              width: width * 0.75,
                              height: 2,
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                "Name : ${userData!["full_name"]}",
                                overflow: TextOverflow.clip,
                                softWrap: true,
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                "degree : ${userData!["degree"]}",
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Year : ${userData!["year_of_study"]}",
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                "Room no : 69",
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            color: Colors.black,
                            width: width * 0.9,
                            height: 1,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Center(
                            child: Text(
                              "BILL DETAILS",
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Hostel Rent:",
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Mess Fees:",
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Maintenace Charges:",
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Late Payment Charges:",
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Other Charges:",
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Total Amount:",
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            color: Colors.black,
                            width: width * 0.9,
                            height: 1,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Note:",
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "● Last day to pay fees without fine is on 31th February.",
                            softWrap: true,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            "●After completing the payment, transaction ID must be uploaded for verification. Failure to provide valid proof may result in payment being considered incomplete. Any attempts of fraud or misrepresentation will be taken seriously and may lead to disciplinary action.",
                            softWrap: true,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  showQRCode(context);
                                },
                                style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStatePropertyAll(buttonColor)),
                                child: Text(
                                  "Pay now",
                                  style: GoogleFonts.poppins(
                                      color: buttonTextColor,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "cancel",
                                    style:
                                        GoogleFonts.poppins(color: Colors.red),
                                  ))
                            ],
                          )
                        ],
                      )),
                ),
              ),
            ),
    );
  }

  String getUpiUrl() {
    return "upi://pay?pa=$upiId&pn=$name&am=$amount&cu=INR&mc=5311&mode=04&purpose=00";
  }

  Future<void> _launchUPI() async {
    final Uri uri = Uri.parse(getUpiUrl());
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print("Could not launch UPI payment app.");
    }
  }

  void showQRCode(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Color.fromRGBO(245, 240, 225, 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(20)), // Rounded top corners
      ),
      context: context,
      builder: (BuildContext context) {
        double width = MediaQuery.of(context).size.width;
        return SizedBox(
          width: width * 0.85,
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 15,
                ),
                QrImageView(
                  backgroundColor: Color.fromRGBO(245, 240, 225, 1),
                  data: getUpiUrl(),
                  version: QrVersions.auto,
                  size: 250,
                ),
                SizedBox(height: 10),
                Text(
                  "Pay using the above QR CODE",
                  style: GoogleFonts.poppins(
                      color: Colors.black, fontWeight: FontWeight.w400),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Mytextfield(
                    bgColor: Colors.grey[200],
                    borderColor: AppColors.borderColor,
                    borderRadius: 15,
                    borderWidth: 1,
                    controller: transcationID,
                    hinttext: "enter the Transaction ID",
                    hintColor: AppColors.hintColor,
                    textColor: AppColors.getTextColor(context),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 15.0, right: 15.0, top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ButtonStyle(
                            backgroundColor:
                                WidgetStatePropertyAll(buttonColor)),
                        child: Text(
                          "Paid",
                          style: GoogleFonts.poppins(
                              color: buttonTextColor,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "cancel",
                          style: GoogleFonts.poppins(color: Colors.red),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
  /**/
}
