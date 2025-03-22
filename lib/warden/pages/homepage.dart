import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

import 'package:minipro/warden/components/my_drawer.dart';
import 'package:minipro/warden/pages/functions/Vacate.dart';
import 'package:minipro/warden/pages/functions/complaints.dart';
import 'package:minipro/warden/pages/functions/maintenance.dart';
import 'package:minipro/warden/pages/functions/menuupdate.dart';
import 'package:minipro/warden/pages/functions/roomchange.dart';
import 'package:minipro/warden/pages/functions/studentapprove.dart';
import 'package:minipro/warden/pages/functions/studentlist.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home',  style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: MyDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 74, 72, 72),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Ionicons.person_circle_outline, size: 40, color: Colors.white),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome back",
                            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Manage your hostel activities",
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w300, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Section Title
              Text("Categories", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
              SizedBox(height: 20.0),

              // Grid Menu
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(), // Prevents internal scrolling
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildMenuItem(Ionicons.hammer_outline, "Maintenance Requests", () => _navigateTo(context, Maintenance())),
                  _buildMenuItem(Ionicons.receipt_outline, "Complaints", () => _navigateTo(context, Complaints())),
                  _buildMenuItem(Ionicons.fast_food_outline, "Mess Menu Update", () => _navigateTo(context, UpdateMessMenu())),
                  _buildMenuItem(Ionicons.people_circle_outline, "Student Approval", () => _navigateTo(context, StudentApproval())),
                  _buildMenuItem(Ionicons.bed_outline, "Room Change", () => _navigateTo(context, RoomChange())),
                  _buildMenuItem(Ionicons.man_outline, "Student List", () => _navigateTo(context, StudentList())),
                  _buildMenuItem(Ionicons.exit_outline, "Vacate Requests", () => _navigateTo(context, VacateRequest())), // Changed icon
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 74, 72, 72),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), spreadRadius: 1, blurRadius: 2, offset: Offset(0, 1)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 16.0, fontWeight: FontWeight.w300, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
