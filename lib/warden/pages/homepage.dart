import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';

import 'package:minipro/warden/components/my_drawer.dart';
import 'package:minipro/warden/pages/functions/allocate.dart';
import 'package:minipro/warden/pages/functions/complaints.dart';
import 'package:minipro/warden/pages/functions/maintenance.dart';
import 'package:minipro/warden/pages/functions/menuupdate.dart';
import 'package:minipro/warden/pages/functions/roomchange.dart';
import 'package:minipro/warden/pages/functions/studentapprove.dart';



//import 'package:google_fonts/google_fonts.dart';
// Import next page

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('Home',style:GoogleFonts.inter (), ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("No new notifications")),
              );
            },
          ),
        ],
      ),
      body: Container(
      
        margin: EdgeInsets.only(top: 20.0,left: 10.0,right: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Categories",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.0),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(7.0),
                child: GridView.count(
                  scrollDirection: Axis.vertical,
                  physics: BouncingScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildMenuItem(
                      Ionicons.hammer_outline,
                      "Maintenance Requests",
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Maintenance(), // Go to next page
                        ),
                      ),
                    ),
                    _buildMenuItem(
                      Ionicons.receipt_outline,
                      "Complaints",
                      ()=>Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Complaints(), // Go to next page
                        ),
                      ), 
                       
                      
                    ),
                    _buildMenuItem(
                      Ionicons.fast_food_outline,
                      "Mess Menu Update",
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdateMessMenu(), // Go to next page
                        ),
                      ),
                    ),
                    

                     _buildMenuItem(
                      Ionicons.people_circle_outline,
                      "Student Approval",
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>StudentApproval(), // Go to next page
                        ),
                      ),
                    ),
                     _buildMenuItem(
                      Ionicons.bed_outline,
                      "Room Change",
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>RoomChange(), // Go to next page
                        ),
                      ),
                    ),


                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: MyDrawer(),
    );
  }

  // FIX: Added onTap parameter
  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap, // Call function when tapped
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 74, 72, 72),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 250, 244, 244).withRed(3),
              spreadRadius: 1,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40,color: Colors.white,),
            SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
             style:GoogleFonts.inter(fontSize: 16.0,fontWeight:FontWeight.w300,color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
