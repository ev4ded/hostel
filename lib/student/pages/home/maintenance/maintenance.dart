import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:minipro/Theme/appcolors.dart';
import 'package:minipro/student/components/custom_route.dart';
import 'package:minipro/student/pages/home/maintenance/maintenanceRequest.dart';
import 'package:minipro/student/Student_queries/queries.dart';

class Maintenance extends StatefulWidget {
  const Maintenance({super.key});

  @override
  State<Maintenance> createState() => _MaintenanceState();
}

class _MaintenanceState extends State<Maintenance> {
  double containerHeight = 65;
  final double borderWidth = 1;
  final Color borderColor = Color.fromRGBO(74, 85, 104, 1);
  Map<String, Color> status = {
    "pending": Colors.amberAccent,
    "approved": Colors.lightGreen,
    "denied": Color.fromRGBO(235, 53, 53, 1)
  };
  @override
  Widget build(BuildContext context) {
    LinearGradient containerColor = AppColors.getcontainerGradient(context);
    Color tileColor = AppColors.getTileColorLight(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(LucideIcons.chevronLeft),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Maintenance Requests..",
          style: GoogleFonts.inter(fontSize: 22),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                child: Container(
                  height: containerHeight,
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor, width: borderWidth),
                    gradient: containerColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "New request",
                            style: GoogleFonts.inter(fontSize: 20),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(LucideIcons.chevronRight),
                        )
                      ],
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.push(context, myRoute(MaintenanceRequest()));
                },
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                "Past Requests",
                style: GoogleFonts.inter(fontSize: 20),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                height: 400,
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: borderWidth),
                  gradient: containerColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: StreamBuilder<List<QueryDocumentSnapshot>>(
                  stream: getStudentMaintenance(
                      FirebaseAuth.instance.currentUser!.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text("Error:${snapshot.error}"),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text("No maintenance requests found"),
                      );
                    }
                    List<QueryDocumentSnapshot> requests = snapshot.data!;
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 5.0, bottom: 5.0, left: 2.0, right: 2.0),
                        child: SizedBox(
                          height: 390,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: AlwaysScrollableScrollPhysics(),
                            itemCount: requests.length,
                            itemBuilder: (context, index) {
                              var request = requests[index].data()
                                  as Map<String, dynamic>;
                              return Card(
                                color: tileColor,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8.0, left: 15, right: 10, bottom: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                request['title'] ?? "No Title",
                                                style: GoogleFonts.inter(
                                                    fontSize: 19,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                request['description'] ??
                                                    "No Description",
                                                style: GoogleFonts.inter(),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: status[request['status']],
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                request['status'] ?? 'Unknown',
                                                style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      if (request['status'] == 'approved')
                                        Row(
                                          children: [
                                            Icon(
                                              LucideIcons.calendarCheck2,
                                              size: 13,
                                            ),
                                            Text(
                                              " Date:  ",
                                              style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                            Text(
                                              request['approvedDate'],
                                              style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                      if (request['status'] == 'approved')
                                        Row(
                                          children: [
                                            Icon(
                                              LucideIcons.clock6,
                                              size: 13,
                                            ),
                                            Text(
                                              " Time:  ",
                                              style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                            Text(
                                              request['approvedTime'].substring(
                                                  0,
                                                  request['approvedTime']
                                                          .length -
                                                      3),
                                              style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
