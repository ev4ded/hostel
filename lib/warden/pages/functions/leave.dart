import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:minipro/warden/services/FCMservices.dart';
import 'package:minipro/warden/wardenQueries/queries.dart';

class LeaveRequests extends StatefulWidget {
  const LeaveRequests({super.key});

  @override
  _LeaveRequestsState createState() => _LeaveRequestsState();
}

class _LeaveRequestsState extends State<LeaveRequests>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? hostelId;
  List<String> studentIds = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchHostelAndStudents();
  }

  void _fetchHostelAndStudents() async {
    String? fetchedHostelId = await fetchHostelId();
    if (fetchedHostelId != null) {
      setState(() {
        hostelId = fetchedHostelId;
      });
      await _fetchStudents();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Unable to fetch Hostel ID'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Leave Management',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo[700],
        bottom: _buildTabBar(),
        elevation: 0,
      ),
      body: hostelId == null
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPendingRequests(),
                _buildStudentsOnLeave(),
              ],
            ),
    );
  }

  PreferredSizeWidget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: Colors.amber[200],
      unselectedLabelColor: Colors.grey[400],
      indicatorColor: Colors.amberAccent.shade100,
      indicatorWeight: 3,
      tabs: [
        Tab(
          child: Text(
            "Pending",
            style: GoogleFonts.dmSans(),
          ),
        ),
        Tab(
          child: Text(
            "Students on Leave",
            style: GoogleFonts.dmSans(),
          ),
        ),
      ],
    );
  }

  Stream<QuerySnapshot> _getPendingLeaveRequests() {
    if (studentIds.isEmpty) {
      return Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('leave_application')
        .where('student_id', whereIn: studentIds)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  Stream<QuerySnapshot> _getStudentsOnLeave() {
    if (studentIds.isEmpty) {
      return Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('leave_application')
        .where('student_id', whereIn: studentIds)
        .where('status', isEqualTo: 'approved')
        .snapshots();
  }

  Future<void> _updateLeaveStatus(String requestId, String status) async {
    try {
      final leaveRef = FirebaseFirestore.instance
          .collection('leave_application')
          .doc(requestId);
      
      final leaveSnapshot = await leaveRef.get();
      if (!leaveSnapshot.exists) {
        print("❌ Leave request not found!");
        return;
      }

      final leaveData = leaveSnapshot.data();
      final studentUid = leaveData?["student_id"];
      if (studentUid == null) {
        print("❌ Student ID not found in leave data!");
        return;
      }

      final studentDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(studentUid)
          .get();

      if (!studentDoc.exists) {
        print("❌ Student not found in users collection!");
        return;
      }

      final fcmTokens = studentDoc["FCM_tokens"] ?? [""];
      if (fcmTokens.isEmpty) {
        await leaveRef.update({'status': status});
        print("❌ No FCM tokens found for the student!");
        return;
      }

      // ✅ Update Firestore: Mark leave request as updated
      await leaveRef.update({'status': status});

      // ✅ Send Notification
      String notificationBody = "Your leave request has been $status.";
      for (var token in fcmTokens) {
        await FCMService.sendNotification(
          fcmToken: token,
          title: "Leave Request Update",
          body: notificationBody,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Leave request $status'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update leave status'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fetchStudents() async {
    if (hostelId == null) return;

    try {
      QuerySnapshot studentsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('hostelId', isEqualTo: hostelId)
          .where('role', isEqualTo: 'student')
          .get();

      List<String> studentList =
          studentsSnapshot.docs.map((doc) => doc.id).toList();

      if (mounted) {
        setState(() {
          studentIds = studentList;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching students'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildPendingRequests() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getPendingLeaveRequests(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
            ),
          );
        }

        var requests = snapshot.data!.docs;

        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/warden/caughtup.png', // Add an appropriate empty state image
                  height: 200,
                ),
                Text(
                  'No Pending Leave Requests',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            var request = requests[index];
            String studentId = request['student_id'];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(studentId)
                  .get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
                    ),
                  );
                }

                if (!userSnapshot.data!.exists) {
                  return Text('User Not Found');
                }

                var user = userSnapshot.data!;
                String username = user['username'] ?? 'Unknown';

                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.blue.shade100],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                               CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.white,
                                backgroundImage: AssetImage('assets/images/profile/${user['dp']}.jpg'),
                              ),
                              Text(
                                username,
                                style: GoogleFonts.roboto(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 103, 119, 245),
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Ionicons.checkmark_circle_sharp, color: Colors.green,size: 35,),
                                    onPressed: () => _updateLeaveStatus(
                                        request.id, 'approved'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          _buildDetailRow('Reason', request['reason']),
                          _buildDetailRow('Type', request['type']),
                          _buildDetailRow('Duration',
                              '${request['from']} to ${request['to']}'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildStudentsOnLeave() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getStudentsOnLeave(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
            ),
          );
        }

        DateTime today = DateTime.now();
        var currentlyOnLeave = snapshot.data!.docs.where((doc) {
          DateTime fromDate = DateFormat('yyyy-MM-dd').parse(doc['from']);
          DateTime toDate = DateFormat('yyyy-MM-dd').parse(doc['to']);
          return fromDate.isBefore(today) && toDate.isAfter(today);
        }).toList();

        if (currentlyOnLeave.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/warden/caughtup.png', // Add an appropriate empty state image
                  height: 200,
                ),
                Text(
                  'No Students Currently on Leave',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: currentlyOnLeave.length,
          itemBuilder: (context, index) {
            var request = currentlyOnLeave[index];
            String studentId = request['student_id'];
          
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(studentId)
                  .get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
                    ),
                  );
                }

                if (!userSnapshot.data!.exists) {
                  return Text('User Not Found');
                }

                var user = userSnapshot.data!;
                String username = user['username'] ?? 'Unknown';

                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.blue.shade100],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.white,
                                backgroundImage: AssetImage('assets/images/profile/${user['dp']}.jpg'),
                              ),
                      title: Text(
                        username,
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 103, 119, 245),
                        ),
                      ),
                      subtitle: Text(
                        'Leave from ${request['from']} to ${request['to']}',
                        style: GoogleFonts.roboto(color: Colors.black),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.bold,
              color: Colors.black54
            ),
          ),
          Text(
            value,
            style: GoogleFonts.roboto(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
