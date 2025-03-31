import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minipro/warden/services/FCMservices.dart';
import 'package:minipro/warden/wardenQueries/queries.dart';

class PaidTransactions extends StatefulWidget {
  const PaidTransactions({super.key});

  @override
  _PaidTransactionsState createState() => _PaidTransactionsState();
}

class _PaidTransactionsState extends State<PaidTransactions> {
  String? hostelId;
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHostelId();
  }

  void _fetchHostelId() async {
    String? fetchedHostelId = await fetchHostelId();
    if (fetchedHostelId != null) {
      setState(() {
        hostelId = fetchedHostelId;
        _fetchPaidTransactions();
      });
    }
  }

  void _fetchPaidTransactions() async {
    if (hostelId == null) return;

    setState(() {
      isLoading = true;
    });

    List<Map<String, dynamic>> transactionsList = [];

    try {
      var paidSnapshot = await FirebaseFirestore.instance
          .collection('hostels')
          .doc(hostelId)
          .collection('paid')
          .get();

      for (var doc in paidSnapshot.docs) {
        String userId = doc.id;
        Map<String, dynamic> data = doc.data();

        var userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
        var userData = userDoc.data()!;
        String dp=userData.containsKey('dp')?userData['dp']:'default';
      
        String userName = (userDoc.exists && userDoc.data() != null)
            ? userDoc.data()!['username'] ?? 'Unknown'
            : 'Unknown';
       
        String transactionId = data.containsKey('transaction_id') ? data['transaction_id'] : 'Unknown';
        String amount = data.containsKey('amount') ? '₹${data['amount']}' : 'N/A';
        String timestamp = data.containsKey('timestamp') 
            ? _formatTimestamp(data['timestamp']) 
            : 'Unknown';

        String paymentStatus = userDoc.exists && userDoc.data()!.containsKey('paid')
            ? userDoc.data()!['paid']
            : 'processing';

        if (paymentStatus == "processing") {
          transactionsList.add({
            'transaction_id': transactionId,
            'user_name': userName,
            'user_id': userId,
            'dp': dp,
            'amount': amount,
            'timestamp': timestamp,
          });
        }
      }

      setState(() {
        transactions = transactionsList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading transactions. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
    return 'Unknown';
  }

  void updatePaymentStatus(String userId, String status) async {
  try {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final userSnapshot = await userRef.get();

    if (!userSnapshot.exists) {
      print("❌ User not found!");
      return;
    }

    final userData = userSnapshot.data();
    final fcmTokens = userData?["FCM_tokens"] ?? [""];

    // ✅ Update Firestore payment status
    await userRef.update({
      'paid': status,
    });

    setState(() {
      transactions.removeWhere((transaction) => transaction['user_id'] == userId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment marked as ${status == "successful" ? "successful" : "failed"}'),
        backgroundColor: status == "successful" ? Colors.green : Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    if (fcmTokens.isEmpty) {
       await userRef.update({
      'paid': status,
    });
      print("❌ No FCM tokens found for the user!");
      return;
    }

    // ✅ Send Notification
    String notificationBody =
        " ${status == "successful" ? "Your payment was Successful" :"Your payment has been Failed"}.";

    for (var token in fcmTokens) {
      await FCMService.sendNotification(
        fcmToken: token,
        title: "Payment Status Update",
        body: notificationBody,
      );
    }

    print("✅ Payment status updated and notification sent.");
  } catch (e) {
    print("❌ Failed to update payment status: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to update payment status'),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
   
    
    return Scaffold(
     
      appBar: AppBar(
        title: Text(
          "Paid Transactions",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchPaidTransactions,
            tooltip: 'Refresh transactions',
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.indigo.shade700,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Loading transactions...",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : transactions.isEmpty
              ? _buildEmptyState()
              : _buildTransactionsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.payment_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            "No pending transactions",
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            "All transactions have been processed",
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 24),
          
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              "Pending Approval (${transactions.length})",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                var transaction = transactions[index];
                
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200, width: 1),
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
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage:AssetImage(
                            'assets/images/profile/${transaction['dp']}.jpg'
                          ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    transaction['user_name'],
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.black
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "Pending",
                                style: GoogleFonts.inter(
                                  color: Colors.amber.shade900,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Divider(height: 24),
                        _buildInfoRow(
                          icon: Icons.receipt_long_outlined,
                          title: "Transaction ID",
                          value: transaction['transaction_id'],
                        ),
                        SizedBox(height: 8),
                        
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _showConfirmationDialog(
                                  transaction['user_id'],
                                  "failed",
                                  transaction['user_name'],
                                ),
                                icon: Icon(Icons.cancel_outlined),
                                label: Text("Decline"),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red.shade700,
                                  side: BorderSide(color: Colors.red.shade200),
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _showConfirmationDialog(
                                  transaction['user_id'],
                                  "successful",
                                  transaction['user_name'],
                                ),
                                icon: Icon(Icons.check_circle_outline),
                                label: Text("Approve"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                 ) );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String title, required String value}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color.fromARGB(255, 21, 11, 11),
        ),
        SizedBox(width: 8),
        Text(
          "$title: ",
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color.fromARGB(255, 17, 7, 7),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color.fromARGB(255, 17, 7, 7),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showConfirmationDialog(String userId, String status, String userName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          status == "successful" ? "Approve Payment" : "Decline Payment",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          status == "successful"
              ? "Are you sure you want to approve the payment from $userName?"
              : "Are you sure you want to decline the payment from $userName?",
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              "Cancel",
              style: GoogleFonts.inter(
                color: Colors.grey[700],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              updatePaymentStatus(userId, status);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: status == "successful" ? Colors.green.shade600 : Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: Text(
              status == "successful" ? "Approve" : "Decline",
              style: GoogleFonts.inter(),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}