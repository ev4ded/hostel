import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:minipro/Admin/adminqueries.dart';
import 'package:minipro/Theme/appcolors.dart';
import 'package:minipro/student/components/myparafield.dart';
import 'package:minipro/student/components/mysnackbar.dart';
import 'package:minipro/student/components/mytextfield.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminProfile extends StatefulWidget {
  const AdminProfile({super.key});

  @override
  State<AdminProfile> createState() => _AdminState();
}

class _AdminState extends State<AdminProfile> {
  final double borderWidth = 1;
  final double borderRadius = 15;
  final Color borderColor = Color.fromRGBO(74, 85, 104, 1);
  Color hintColor = AppColors.hintColor;
  Color buttonColor = AppColors.buttonColor;
  Color buttonTextColor = AppColors.buttonTextColor;
  final rentController = TextEditingController();
  final latefineController = TextEditingController();
  final locationController = TextEditingController();
  final maintenanceChargeController = TextEditingController();
  final messfeesController = TextEditingController();
  final otherchargesController = TextEditingController();
  final upiController = TextEditingController();
  final nameController = TextEditingController();
  bool isloading = true;
  String? hostelID;

  @override
  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    String? id = await fetchAdminHostelId();
    setState(() {
      hostelID = id;
    });
    if (hostelID != null) {
      Map<String, dynamic>? temp = await getHostelDetails(hostelID!);
      print(temp);
      setState(() {
        nameController.text = temp!['Admin_name'] ?? "";
        locationController.text = temp["location"] ?? "";
        upiController.text = temp['upi'] ?? "";
        rentController.text = temp["hostel_rent"].toString();
        latefineController.text = temp["late_fine"].toString();
        maintenanceChargeController.text =
            temp["maintenance_charge"].toString();
        messfeesController.text = temp["mess_fees"].toString();
        otherchargesController.text = temp["other_charges"].toString();
        isloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = AppColors.getContainerColor(context);
    Color textColor = AppColors.getTextColor(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(LucideIcons.chevronLeft)),
        title: Text(
          "Hostel Details",
          style: GoogleFonts.poppins(fontSize: 22),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: (isloading)
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Full Name",
                      style: GoogleFonts.poppins(),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Mytextfield(
                      controller: nameController,
                      textColor: textColor,
                      borderRadius: borderRadius,
                      borderColor: borderColor,
                      hinttext: "Enter your full name",
                      bgColor: bgColor,
                      hintColor: hintColor,
                    ),
                    SizedBox(height: 15),
                    Text(
                      "Address",
                      style: GoogleFonts.poppins(),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Myparafield(
                      controller: locationController,
                      noOfLine: 4,
                      textColor: textColor,
                      borderRadius: borderRadius,
                      borderColor: borderColor,
                      hintText: "Exact location",
                      bgColor: bgColor,
                      hintColor: hintColor,
                    ),
                    SizedBox(height: 15),
                    Text("UPI ID"),
                    Mytextfield(
                      controller: upiController,
                      textColor: textColor,
                      borderRadius: borderRadius,
                      borderColor: borderColor,
                      hinttext: "UPI ID of the hostel",
                      bgColor: bgColor,
                      hintColor: hintColor,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Fees Details",
                      style: GoogleFonts.poppins(),
                    ),
                    SizedBox(height: 10),
                    Mytextfield(
                      controller: rentController,
                      type: TextInputType.number,
                      textColor: textColor,
                      borderRadius: borderRadius,
                      borderColor: borderColor,
                      hinttext: "Rent amount",
                      bgColor: bgColor,
                      hintColor: hintColor,
                    ),
                    SizedBox(height: 15),
                    Mytextfield(
                      controller: latefineController,
                      type: TextInputType.number,
                      textColor: textColor,
                      borderRadius: borderRadius,
                      borderColor: borderColor,
                      hinttext: "late fine amount",
                      bgColor: bgColor,
                      hintColor: hintColor,
                    ),
                    SizedBox(height: 15),
                    Mytextfield(
                      controller: maintenanceChargeController,
                      type: TextInputType.number,
                      textColor: textColor,
                      borderRadius: borderRadius,
                      borderColor: borderColor,
                      hinttext: "maintenance amount",
                      bgColor: bgColor,
                      hintColor: hintColor,
                    ),
                    SizedBox(height: 15),
                    Mytextfield(
                      controller: messfeesController,
                      type: TextInputType.number,
                      textColor: textColor,
                      borderRadius: borderRadius,
                      borderColor: borderColor,
                      hinttext: "mess fees",
                      bgColor: bgColor,
                      hintColor: hintColor,
                    ),
                    SizedBox(height: 15),
                    Mytextfield(
                      controller: otherchargesController,
                      type: TextInputType.number,
                      textColor: textColor,
                      borderRadius: borderRadius,
                      borderColor: borderColor,
                      hinttext: "other charges",
                      bgColor: bgColor,
                      hintColor: hintColor,
                    ),
                    SizedBox(height: 15),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            submit();
                          },
                          style: ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(buttonColor)),
                          child: Text(
                            "Submit",
                            style: GoogleFonts.poppins(
                                color: buttonTextColor,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> saveLoginState(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }

  void submit() {
    String name = nameController.text.trim();
    String address = locationController.text.trim();
    String upi = upiController.text.trim();
    String rent = rentController.text.trim();
    String latefine = latefineController.text.trim();
    String maintenance = maintenanceChargeController.text.trim();
    String mess = messfeesController.text.trim();
    String other = otherchargesController.text.trim();
    if (name.isEmpty ||
        address.isEmpty ||
        upi.isEmpty ||
        rent.isEmpty ||
        latefine.isEmpty ||
        maintenance.isEmpty ||
        mess.isEmpty ||
        other.isEmpty) {
      _showSnackBar("please fill in all the fields", isError: true);
      return;
    }
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection('hostels').doc(hostelID).set({
        'Admin_name': name,
        'hostel_rent': int.tryParse(rent),
        'late_fine': int.tryParse(latefine),
        'location': address,
        'maintenance_charge': int.tryParse(maintenance),
        'mess_fees': int.tryParse(mess),
        'other_charges': int.tryParse(other),
        'paid': false,
        'upi': upi,
      });
      _showSnackBar("details updated");
      Future.delayed(Duration(seconds: 1), () {
        if (context.mounted) {
          Navigator.pop(context);
        }
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    Mysnackbar.show(context, message, isError: isError);
  }
}
