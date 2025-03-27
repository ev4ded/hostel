import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:minipro/firebase/firestore_services.dart';
import 'package:minipro/student/pages/profile/changepassword.dart';
import 'package:minipro/warden/pages/functions/editprofile.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final FirestoreServices _firestoreService = FirestoreServices();
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    setState(() {
    isLoading = true;
   });
await _firestoreService.getUserData();
    Map<String, dynamic>? cachedUserData =
        await _firestoreService.getCachedUserData();
    
    if (cachedUserData != null) {
      setState(() {
        userData = cachedUserData;
        isLoading = false;
      });
    } else {
      await _firestoreService.getUserData();
      Map<String, dynamic>? newUserData =
          await _firestoreService.getCachedUserData();
      setState(() {
        userData = newUserData;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
       
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Ionicons.alert_circle_outline, size: 48, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        "Error fetching data",
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: fetchUserData,
                        child: Text("Retry"),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Header with Background
                      Container(
                        padding: const EdgeInsets.only(top: 30, bottom: 30),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Profile Avatar
                            Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color.fromARGB(255, 74, 72, 72), width: 2),
                                  ),
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundColor: Colors.grey[100],
                                    child: Text(
                                      _getInitials(userData?['username'] ?? 'W'),
                                      style: GoogleFonts.inter(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        color: const Color.fromARGB(255, 74, 72, 72),
                                      ),
                                    ),
                                  ),
                                ),
                              
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Warden Name
                            Text(
                              userData?['username'] ?? 'Warden Name',
                              style: GoogleFonts.inter(fontSize: 24, color: Colors.black,fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),

                            // Email
                            Text(
                              userData?['email'] ?? 'Email not found',
                              style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),

                      // Profile Details Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionHeader("Profile Information"),
                            _profileInfoCard(),
                            
                            const SizedBox(height: 24),
                            
                            _sectionHeader("Account Settings"),
                            _buildSettingsButton(
                            userData == null || userData!.isEmpty ? "Build Profile" : "Edit Profile",
                            Ionicons.create_outline,
                            "Update your profile information",
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditWardenProfile(),
                                ),
                              ).then((_) => fetchUserData()); // Refresh data after edit
                            },
                          ),

                            _buildSettingsButton(
                              "Change Password",
                              Ionicons.lock_closed_outline,
                              "Update your security credentials",
                              () {
                                Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Changepassword(),
                                ),
                              );
                              },
                            ),
                          
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                    ],
                  ),
                ),
    );
  }

 String _getInitials(String name) {
  return name.isNotEmpty ? name[0].toUpperCase() : '';
}

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          
        ),
      ),
    );
  }

  Widget _profileInfoCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _infoItem(
              Icons.castle_outlined,
              "Hostel ID",
              userData?['hostelId'] ?? 'No Hostel Assigned',
            ),
            const Divider(height: 24),
            _infoItem(
              Ionicons.logo_whatsapp,
              "Phone",
              userData?['phone_no'] ?? 'Not provided',
            ),
            const Divider(height: 24),
            _infoItem(
              Ionicons.business_outline,
              "Hostel",
              userData?['hostel_name'] ?? 'Not specified',
            ),
            const Divider(height: 24),
             _infoItem(
              Ionicons.location_outline,
              "Location",
              userData?['location'] ?? 'Not specified',
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 74, 72, 72).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color.fromARGB(255, 74, 72, 72),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsButton(
    String title,
    IconData icon,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 74, 72, 72).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: const Color.fromARGB(255, 74, 72, 72),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}