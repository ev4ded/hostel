import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:ionicons/ionicons.dart';
import 'package:minipro/warden/pages/functions/studentlist.dart';
import 'package:minipro/warden/pages/profile.dart';
import 'homepage.dart';


class MyNavigation extends StatefulWidget {
 final int selectedIndex ;
  const MyNavigation({super.key,
    this.selectedIndex = 0,
  });

  @override
  State<MyNavigation> createState() => _MyNavigationState();
}

class _MyNavigationState extends State<MyNavigation> {
  int _selectedIndex = 0;
  static const List<Widget> _pages = <Widget>[
    HomePage(),
    StudentList(),
    MyProfile(),
  
  ];
  
  @override
  void initState() {
    
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _pages.elementAt(_selectedIndex)),
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
          child: GNav(
            curve: Curves.easeOutExpo,
            duration: Duration(milliseconds: 200),
            backgroundColor: Colors.black,
            color:  Colors.white,
            activeColor: Colors.white,
            textStyle:GoogleFonts.pixelifySans(fontWeight:FontWeight.bold,color: Colors.white), 
            tabBackgroundColor: const Color.fromARGB(255, 74, 72, 72),
            padding: EdgeInsets.all(16),
            gap: 7,
            tabs:  [
              GButton(
                icon: _selectedIndex == 0 ? Ionicons.home : Ionicons.home_outline,
                text: 'Home',
              ),
              GButton(
                icon: _selectedIndex==1? Ionicons.man : Ionicons.man_outline,
                text: 'Student List',
              ),
              GButton(
                icon: _selectedIndex==2? Ionicons.person : Ionicons.person_outline,
                text: 'Profile',
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
