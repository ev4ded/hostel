import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:minipro/Theme/appcolors.dart';
import 'package:minipro/firebase/firestore_services.dart';
import 'package:minipro/student/Student_queries/queries.dart';
import 'package:minipro/student/components/custom_route.dart';
import 'package:minipro/student/components/mysnackbar.dart';
import 'package:minipro/student/components/mytextfield.dart';
import 'package:minipro/student/pages/home/complaint/complaint.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Payment extends StatefulWidget {
  const Payment({super.key});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  late final String upiId; // Replace with your UPI ID
  final String name = "Hostel Management";
  late final String amount;
  Color buttonColor = AppColors.buttonColor;
  Color buttonTextColor =
      AppColors.buttonTextColor; //overflows when name is too large
  final FirestoreServices _firestoreService = FirestoreServices();
  final transcationID = TextEditingController();
  Map<String, dynamic>? userData;
  Map<String, dynamic>? user;
  int rent = 0;
  int messfees = 0;
  int maintenancefees = 0;
  int fine = 0;
  int otherfees = 0;
  int total = 0;
  bool paymenttime = false;
  String paid = "";
  bool isloading = true;
  bool paymentdone = false;
  int month = DateTime.now().month - 1;
  String? mode;
  int finecount = 0;
  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchUser();
    fetchUserData();
  }

  void fetchUserData() async {
    Map<String, dynamic>? userDetails =
        await _firestoreService.getUserDetails();
    Map<String, dynamic>? hostelDetails =
        await _firestoreService.getHostelDetails(user?["hostelId"]);
    if (month == 0) {
      setState(() {
        month = 12;
      });
    }
    int count = await countDays(month);
    if (mounted) {
      setState(() {
        userData = userDetails;
        rent = hostelDetails?["hostel_rent"] ?? 0;
        messfees = hostelDetails?["mess_fees"] ?? 0;
        maintenancefees = hostelDetails?["maintenance_charge"] ?? 0;
        fine = hostelDetails?["late_fine"] ?? 0;
        otherfees = hostelDetails?["other_charges"] ?? 0;
        amount = total.toString();
        paid = userDetails?["paid"] ?? "";
        upiId = hostelDetails?["upi"];
        paymenttime = hostelDetails?["paymentTime"] ?? false;
        mode = hostelDetails?["payment_mode"];
        if (DateTime.now().day > 7 && paid == "") {
          finecount = DateTime.now().day - 7;
        }
        fine = fine * finecount;
        if (mode == 'Daily basis') {
          rent = rent * count;
          messfees = messfees * count;
        }
        total = rent + messfees + maintenancefees + fine + otherfees;
        isloading = false;
      });
      print("fine count:$finecount");
    }
  }

  void fetchUser() async {
    Map<String, dynamic>? cachedUserData =
        await _firestoreService.getCachedUserData();
    if (cachedUserData != null) {
      setState(() {
        user = cachedUserData;
      });
    } else {
      await _firestoreService.getUserData();
      Map<String, dynamic>? newUserData =
          await _firestoreService.getCachedUserData();
      setState(() {
        user = newUserData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          "Payment ",
          style: GoogleFonts.inter(letterSpacing: 2, fontSize: 20),
        ),
        leading: IconButton(
          icon: Icon(LucideIcons.chevronLeft),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: (isloading)
          ? Center(child: CircularProgressIndicator())
          : getWidget(),
    );
  }

  Widget getWidget() {
    double width = MediaQuery.of(context).size.width;
    if (paymenttime) {
      if (paid == "") {
        setState(() {
          paymentdone = false;
        });
        return SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(
                left: 20.0, right: 20, top: 40, bottom: 40),
            child: Center(
              child: Container(
                width: width * 0.9,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(215, 210, 195, 1),
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
                          "Bill for ${DateFormat('MMMM').format(DateTime(now.year, now.month - 1)).toUpperCase()} month",
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
                            "Name : ${userData!["username"]}",
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
                            "Room no : ${userData!["room_no"]}",
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
                        "Hostel Rent: $rent",
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Mess Fees: $messfees",
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Maintenace Charges: $maintenancefees",
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Late Payment Charges: $fine",
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Other Charges: $otherfees",
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Total Amount: $total",
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
                        "● Last day to pay fees without fine is on 7th of ${DateFormat('MMMM').format(now).toUpperCase()}.",
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
                              style: GoogleFonts.poppins(color: Colors.red),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      } else if (paid == "processing") {
        return Container(
          color: AppColors.getAlertWindowC(context),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 350, // Set the desired height
                  width: 350,
                  child: Image.asset(
                    "assets/images/searching.png",
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Payment is being processed..",
                  style: GoogleFonts.poppins(
                      color: AppColors.getTextColor(context), fontSize: 18),
                )
              ],
            ),
          ),
        );
      } else if (paid == "failed") {
        return Container(
          color: AppColors.getAlertWindowC(context),
          child: Center(
            child: SizedBox(
              width: double.infinity, // Ensures the Column takes full width
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Ensure text is centered
                children: [
                  SizedBox(
                    height: 300,
                    width: 300,
                    child: Image.asset(
                      "assets/images/sad.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Payment failed. Please try again or raise a complaint",
                    textAlign: TextAlign
                        .center, // Ensures multi-line text stays centered
                    style: GoogleFonts.poppins(
                      color: AppColors.getTextColor(context),
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            paid = "";
                          });
                        },
                        style: ButtonStyle(
                            backgroundColor:
                                WidgetStatePropertyAll(AppColors.buttonColor)),
                        child: Text(
                          "Pay again",
                          style: GoogleFonts.inter(
                              color: AppColors.buttonTextColor,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            Navigator.pushReplacement(
                              context,
                              myRoute(
                                Complaint(),
                              ),
                            );
                          });
                        },
                        style: ButtonStyle(
                            backgroundColor:
                                WidgetStatePropertyAll(Colors.red)),
                        child: Text(
                          "Complain",
                          style: GoogleFonts.inter(
                              color: AppColors.buttonTextColor,
                              fontWeight: FontWeight.w500),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      } else {
        return Container(
          color: AppColors.getAlertWindowC(context),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 350, // Set the desired height
                  width: 350,
                  child: Image.asset(
                    "assets/images/paid.png",
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Payment is successfull!!!",
                  style: GoogleFonts.poppins(
                      color: AppColors.getTextColor(context), fontSize: 18),
                ),
                SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        );
      }
    } else {
      var useruid = FirebaseAuth.instance.currentUser!.uid;
      FirebaseFirestore.instance
          .collection("users")
          .doc(useruid)
          .update({'paid': ""});
      return Container(
        color: AppColors.getAlertWindowC(context),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 350, // Set the desired height
                width: 350,
                child: Image.asset(
                  "assets/images/feesnotyet.png",
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "nothing to pay for yet",
                style: GoogleFonts.poppins(
                    color: AppColors.getTextColor(context), fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }
  }

  String getUpiUrl() {
    return "upi://pay?pa=$upiId&pn=$name&am=$amount&cu=INR&mc=5311&mode=04&purpose=00";
  }

  void showQRCode(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Color.fromRGBO(230, 225, 210, 1),
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
            padding: const EdgeInsets.only(top: 10.0, bottom: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 5,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Text(
                      "Transaction ID:",
                      style: GoogleFonts.poppins(
                          color: Colors.black, fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Mytextfield(
                    type: TextInputType.number,
                    bgColor: AppColors.containerColorLight,
                    borderColor: AppColors.borderColor,
                    borderRadius: 15,
                    borderWidth: 1,
                    controller: transcationID,
                    hinttext: "enter the Transaction ID",
                    hintColor: AppColors.hintColor,
                    textColor: Colors.black,
                  ),
                ),
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
                Padding(
                  padding:
                      const EdgeInsets.only(left: 15.0, right: 15.0, top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          paying();
                        },
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

  void paying() {
    if (transcationID.text.isEmpty) {
      Navigator.of(context).pop();
      _showSnackBar("enter Transaction ID", isError: true);
      return;
    }
    User? tuser = FirebaseAuth.instance.currentUser;
    if (tuser != null) {
      try {
        FirebaseFirestore.instance
            .collection("hostels")
            .doc(user?["hostelId"])
            .collection("paid")
            .doc(tuser.uid)
            .set({
          'transaction_id': transcationID.text.trim(),
        });
        Navigator.of(context).pop();
        FirebaseFirestore.instance.collection("users").doc(tuser.uid).update({
          'paid': 'processing',
        });
        Navigator.of(context).pop();
        _showSnackBar("Fess payment processing began..");
      } catch (e) {
        print(e.toString());
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    Mysnackbar.show(context, message, isError: isError);
  }

  void done() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'paid': ""});
    } catch (e) {
      print("Firestore update failed: $e");
    }
  }
}
