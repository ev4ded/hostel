import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:minipro/student/Student_queries/queries.dart';
import 'package:minipro/student/components/custom_route.dart';
import 'package:minipro/student/pages/home/complaint/cregister.dart';

class Complaint extends StatefulWidget {
  const Complaint({super.key});

  @override
  State<Complaint> createState() => _ComplaintState();
}

class _ComplaintState extends State<Complaint> {
  double containerHeight = 65;
  Color containerColor = Color.fromRGBO(40, 40, 40, 1);
  Color tileColor = Color.fromRGBO(78, 68, 64, 1);
  final Color borderColor = Color.fromRGBO(74, 85, 104, 1);
  Map<String, Color> status = {
    "pending": Color.fromRGBO(181, 139, 96, 1),
    "resolved": Color.fromRGBO(46, 125, 50, 1),
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                "Complaint Requests..",
                style: GoogleFonts.inter(fontSize: 22),
              ),
              SizedBox(
                height: 25,
              ),
              GestureDetector(
                child: Container(
                  height: containerHeight,
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor, width: 0.5),
                    color: containerColor,
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
                  Navigator.push(context, myRoute(Cregister()));
                },
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                "Previous Complaints",
                style: GoogleFonts.inter(fontSize: 20),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                height: 400,
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor),
                  color: containerColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: FutureBuilder<List<QueryDocumentSnapshot>>(
                  future: getStudentComplaint(
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
                            physics: AlwaysScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: requests.length,
                            itemBuilder: (context, index) {
                              var request = requests[index].data()
                                  as Map<String, dynamic>;
                              return Card(
                                color: tileColor,
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: Text(
                                    request['title'] ?? "No Title",
                                    style: GoogleFonts.inter(),
                                  ),
                                  subtitle: Text(
                                    request['description'] ?? "No Description",
                                    style: GoogleFonts.inter(fontSize: 12),
                                  ),
                                  trailing: Container(
                                    decoration: BoxDecoration(
                                      color: status[request['status']],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        request['status'] ?? 'Unknown',
                                        style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
