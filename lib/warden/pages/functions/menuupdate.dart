import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:minipro/student/components/mytextfield.dart';

class UpdateMessMenu extends StatefulWidget {
  const UpdateMessMenu({super.key});

  @override
  _UpdateMessMenuState createState() => _UpdateMessMenuState();
}

class _UpdateMessMenuState extends State<UpdateMessMenu> {
  final TextEditingController _breakfastController = TextEditingController();
  final TextEditingController _lunchController = TextEditingController();
  final TextEditingController _snacksController = TextEditingController();
  final TextEditingController _dinnerController = TextEditingController();
  String? hostelId;

  @override
  void initState() {
    super.initState();
    fetchHostelId();
  }

  /// Fetch the hostel ID of the logged-in warden
  Future<void> fetchHostelId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: user.email)
        .where("role", isEqualTo: "warden")
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        hostelId = snapshot.docs.first["hostelId"];
      });
      print("Fetched Hostel ID: $hostelId");
    } else {
      print("No hostel ID found for this warden.");
    }
  }

  /// Update the mess menu for the hostel
  Future<void> updateMessMenu() async {
    if (hostelId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hostel ID not found. Try logging in again.")),
      );
      return;
    }

    if (_breakfastController.text.isEmpty ||
        _lunchController.text.isEmpty ||
        _snacksController.text.isEmpty ||
        _dinnerController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter all meals")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection("mess_menu")
          .doc(hostelId) // Use correct hostel ID
          .set({
        "breakfast": _breakfastController.text,
        "lunch": _lunchController.text,
        "snacks":_snacksController.text,
        "dinner": _dinnerController.text
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Mess menu updated successfully!")),
      );

      _breakfastController.clear();
      _lunchController.clear();
      _snacksController.clear();
      _dinnerController.clear();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating menu: $error")),
      );
    }
  }
  
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      appBar: AppBar(title: Text("Update Mess Menu", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
         
            children: [
               _buildMealCard("breakfast", _breakfastController, Icons.free_breakfast),
              _buildMealCard("lunch", _lunchController, Icons.restaurant),
              _buildMealCard("snacks", _snacksController, Icons.fastfood),
              _buildMealCard("dinner", _dinnerController, Icons.dinner_dining),
        
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: updateMessMenu,
        label: Text("Update Menu"),
        icon: Icon(Ionicons.save),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// 🔥 Custom Card UI for Meals
  Widget _buildMealCard(String mealType, TextEditingController controller, IconData icon) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey),
            SizedBox(width: 20),
            Expanded(
              child: Mytextfield(
                hinttext: "Enter $mealType Item",
                controller: controller,
                textColor: Colors.grey,
              ),
              
            ),
          ],
        ),
      ),
    );
  }
}
