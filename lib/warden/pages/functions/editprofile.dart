import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:minipro/Theme/appcolors.dart';
import 'package:minipro/firebase/firestore_services.dart';
import 'package:minipro/student/components/custom_route.dart';
import 'package:minipro/student/components/mysnackbar.dart';
import 'package:minipro/student/components/mytextfield.dart';
import 'package:minipro/student/components/mydropdownmenu.dart';
import 'package:minipro/warden/pages/navigation.dart';

class EditWardenProfile extends StatefulWidget {
  const EditWardenProfile({super.key});

  @override
  State<EditWardenProfile> createState() => _EditWardenProfileState();
}

class _EditWardenProfileState extends State<EditWardenProfile> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _hostelController = TextEditingController();
  String designation = "";
  String gender = "";

  final FirestoreServices _firestoreService = FirestoreServices();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    setState(() {
      isLoading = true;
    });
await _firestoreService.getUserData();
    Map<String, dynamic>? cachedData = await _firestoreService.getCachedUserData();
    if (cachedData == null) {
      await _firestoreService.getUserData();
      cachedData = await _firestoreService.getCachedUserData();
    }

    if (cachedData != null) {
      setState(() {
        _nameController.text = cachedData?["username"] ?? "";
        _phoneController.text = cachedData?["phone_no"] ?? "";
        _emailController.text = cachedData?["email"] ?? "";
        _hostelController.text = cachedData?["hostel_name"] ?? "";
        designation = cachedData?["designation"] ?? "";
        gender = cachedData?["gender"] ?? "";
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = AppColors.getTextColor(context);
    Color bgColor = AppColors.getContainerColor(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Warden Profile",
           style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: Icon(LucideIcons.chevronLeft),
          onPressed: () {
           Navigator.push(
                context,
                myRoute(
                  MyNavigation(
                   selectedIndex: 2,
                  ),
                ),
              );
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Full Name"),
                  Mytextfield(
                    controller: _nameController,
                    hinttext: "Enter full name",
                    bgColor: bgColor,
                    textColor: textColor,
                  ),
                  SizedBox(height: 20),
                  
                  _buildLabel("Phone No"),
                  Mytextfield(
                    controller: _phoneController,
                    hinttext: "Enter phone number",
                    type: TextInputType.phone,
                    bgColor: bgColor,
                    textColor: textColor,
                  ),
                  SizedBox(height: 20),

                  _buildLabel("Email"),
                  Mytextfield(
                    controller: _emailController,
                    hinttext: "Enter email",
                    type: TextInputType.emailAddress,
                    bgColor: bgColor,
                    textColor: textColor,
                  ),
                  SizedBox(height: 20),

                  _buildLabel("Hostel Name"),
                  Mytextfield(
                    controller: _hostelController,
                    hinttext: "Enter hostel name",
                    bgColor: bgColor,
                    textColor: textColor,
                  ),
                  SizedBox(height: 20),

                  _buildLabel("Designation"),
                  Mydropdownmenu(
                    list: ["Senior Warden", "Assistant Warden"],
                    hinttext: designation.isEmpty ? "Select designation" : designation,
                    bgColor: bgColor,
                    textColor: textColor,
                    defaultvalue: designation.isNotEmpty ? designation : null,
                    getvalue: (value) {
                      setState(() {
                        designation = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),

                  _buildLabel("Gender"),
                  Mydropdownmenu(
                    list: ["Male", "Female"],
                    hinttext: gender.isEmpty ? "Select gender" : gender,
                    bgColor: bgColor,
                    textColor: textColor,
                    defaultvalue: gender.isNotEmpty ? gender : null,
                    getvalue: (value) {
                      setState(() {
                        gender = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),

                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: () {
                        submit();
                      },
                      style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(AppColors.buttonColor)),
                      child: Text(
                        "Save",
                        style: GoogleFonts.inter(
                            color: AppColors.buttonTextColor, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
    );
  }

  Future<void> submit() async {
    String name = _nameController.text;
    String phone = _phoneController.text;
    String email = _emailController.text;
    String hostel = _hostelController.text;
    if(phone.length != 10){
      _showSnackBar("Phone number must be 10 digits", isError: true);
      return;
    }

    if (name.isEmpty || phone.isEmpty || email.isEmpty || hostel.isEmpty || designation.isEmpty || gender.isEmpty) {
      _showSnackBar("Please fill in all fields", isError: true);
    } else {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          DocumentReference docRef =
              FirebaseFirestore.instance.collection("users").doc(user.uid);
          await docRef.update({
            'username': name,
            'phone_no': phone,
            'email': email,
            'hostel_name': hostel,
            'designation': designation,
            'gender': gender,
            "profileUpdated": true
          });

          _showSnackBar("Updated successfully");
          Future.delayed(Duration(seconds: 1), () {
            if (context.mounted) {
             Navigator.push(
                context,
                myRoute(
                  MyNavigation(
                   selectedIndex: 2,
                  ),
                ),
              );
            }
          });
        } catch (e) {
          _showSnackBar("Update failed", isError: true);
        }
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    Mysnackbar.show(context, message, isError: isError);
  }
}
