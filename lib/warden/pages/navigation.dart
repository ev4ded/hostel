import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:ionicons/ionicons.dart';
import 'package:minipro/warden/pages/settingspage.dart';
import 'homepage.dart';
import 'profile.dart';

class MyNavigation extends StatefulWidget {
  const MyNavigation({super.key});

  @override
  State<MyNavigation> createState() => _MyNavigationState();
}

class _MyNavigationState extends State<MyNavigation> {
  int _selectedIndex = 0;
  static const List<Widget> _pages = <Widget>[
    HomePage(),
    MyProfile(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _pages.elementAt(_selectedIndex)),
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
          child: GNav(
            curve: Curves.easeInOutQuint,
            duration: Duration(milliseconds: 200),
            backgroundColor: Colors.black,
            color:  Colors.white,
            activeColor: Colors.white,
            textStyle:GoogleFonts.pixelifySans(fontWeight:FontWeight.bold,color: Colors.white), 
            tabBackgroundColor: const Color.fromARGB(255, 74, 72, 72),
            padding: EdgeInsets.all(16),
            gap: 7,
            tabs: const [
              GButton(
                icon: Ionicons.home_outline,
                text: 'Home',
              ),
              GButton(
                icon: Ionicons.person_outline,
                text: 'Profile',
              ),
              GButton(
                icon: Ionicons.settings_outline,
                text: 'Settings',
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
