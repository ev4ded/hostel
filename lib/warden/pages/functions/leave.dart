import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
      await FirebaseFirestore.instance
          .collection('leave_application')
          .doc(requestId)
          .update({'status': status});

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
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
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
                                  icon: Icon(Icons.check, color: Colors.green),
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
                  child: ListTile(
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
                      style: GoogleFonts.roboto(),
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
            ),
          ),
          Text(
            value,
            style: GoogleFonts.roboto(),
          ),
        ],
      ),
    );
  }
}
