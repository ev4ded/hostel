import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minipro/warden/wardenQueries/queries.dart';

class PaidTransactions extends StatefulWidget {
  const PaidTransactions({super.key});

  @override
  _PaidTransactionsState createState() => _PaidTransactionsState();
}

class _PaidTransactionsState extends State<PaidTransactions> {
  String? hostelId;

  @override
  void initState() {
    super.initState();
    _fetchHostelId();
  }

  // Fetch warden's hostel ID
  void _fetchHostelId() async {
    String? fetchedHostelId = await fetchHostelId();
    if (fetchedHostelId != null) {
      setState(() {
        hostelId = fetchedHostelId;
      });
    }
  }

  // Fetch transactions from the 'paid' collection in the hostel
  Future<List<Map<String, dynamic>>> fetchPaidTransactions() async {
    if (hostelId == null) return [];

    List<Map<String, dynamic>> transactionsList = [];

    // Step 1: Get all user payment documents from 'paid'
    var paidSnapshot = await FirebaseFirestore.instance
        .collection('hostels')
        .doc(hostelId)
        .collection('paid')
        .get();

    for (var doc in paidSnapshot.docs) {
      String userId = doc.id; // User ID is the document ID
      Map<String, dynamic> data = doc.data();

      // Step 2: Fetch user details from 'users' collection
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      String userName = (userDoc.exists && userDoc.data() != null)
          ? userDoc.data()!['username'] ?? 'Unknown'
          : 'Unknown';

      // Step 3: Extract transaction ID (assuming it is stored under a specific key, like 'transaction_id')
      String transactionId = data.containsKey('transaction_id')
          ? data['transaction_id']
          : 'Unknown';

      // Step 4: Add to the transaction list
      transactionsList.add({
        'transaction_id': transactionId,
        'user_name': userName,
      });
    }

    return transactionsList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Paid Transactions",
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
      ),
      body: hostelId == null
          ? Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchPaidTransactions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error fetching transactions"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No transactions found"));
                }

                var transactions = snapshot.data!;
                return ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    var transaction = transactions[index];
                    return Card(
                      margin: EdgeInsets.all(10),
                      elevation: 3,
                      child: ListTile(
                        title: Text("Paid by: ${transaction['user_name']}"),
                        subtitle: Text(
                            "Transaction ID: ${transaction['transaction_id']}"),
                        leading: Icon(Icons.payment, color: Colors.green),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
