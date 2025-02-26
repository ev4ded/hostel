import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Maintenance extends StatefulWidget {
  const Maintenance({super.key});

  @override
  _MaintenanceState createState() => _MaintenanceState();
}

class _MaintenanceState extends State<Maintenance>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text("Maintenance Requests"), bottom: _buildTabBar()),
      body: TabBarView(
        controller: _tabController,
        children: [
          RequestsList(
              status: "Pending",
              hostel_id: "123"), // Replace with actual hostel ID
          RequestsList(
              status: "Approved",
              hostel_id: "123"), // Replace with actual hostel ID
          RequestsList(
              status: "Denied",
              hostel_id: "123"), // Replace with actual hostel ID
        ],
      ),
    );
  }

  // Custom TabBar with Underline
  PreferredSizeWidget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: const Color.fromARGB(255, 250, 244, 244)
          .withRed(3), // Active tab color
      unselectedLabelColor:
          const Color.fromARGB(255, 220, 200, 200), // Inactive tab color
      indicatorColor: const Color.fromARGB(255, 250, 244, 244)
          .withRed(3), // Underline color
      indicatorWeight: 3, // Thickness of the underline
      tabs: [
        Tab(text: "Pending"),
        Tab(text: "Approved"),
        Tab(text: "Denied"),
      ],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// Widget to Fetch & Display Requests Based on Status
class RequestsList extends StatelessWidget {
  final String status;
  final String hostel_id;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RequestsList({super.key, required this.status, required this.hostel_id});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection("maintenance_request")
          .where("status",
              isEqualTo: status.toLowerCase()) // Ensure lowercase match
          .where("hostel_id", isEqualTo: hostel_id)
          .orderBy("created_at", descending: true) // Ordering by created_at
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(
              "Firestore Error: ${snapshot.error}"); // <-- Log Firestore error
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No $status Requests Found"));
        }

        var requests = snapshot.data!.docs;
        print("Fetched ${requests.length} documents");

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            var request = requests[index];
            Map<String, dynamic> requestData =
                request.data() as Map<String, dynamic>;

            // Extract request_id safely
            String requestId = requestData["request_id"] ?? request.id;

            return Card(
              margin: EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(requestData["title"] ?? "No Title"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Room No: ${requestData["room no"] ?? "No Room"}"),
                    Text(requestData["description"] ?? "No Description"),
                  ],
                ),
                trailing: status == "Pending"
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () =>
                                updateStatus(requestId, "approved", context),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green),
                            child: Text("Approve"),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () =>
                                updateStatus(requestId, "denied", context),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            child: Text("Deny"),
                          ),
                        ],
                      )
                    : Icon(
                        status == "Approved"
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: status == "Approved" ? Colors.green : Colors.red,
                      ),
              ),
            );
          },
        );
      },
    );
  }

  void updateStatus(
      String requestId, String newStatus, BuildContext context) async {
    try {
      await _firestore
          .collection("maintenance_request")
          .doc(requestId)
          .update({"status": newStatus.toLowerCase()});
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Status updated to $newStatus")));
    } catch (e) {
      print("Error updating status: $e");
    }
  }
}
