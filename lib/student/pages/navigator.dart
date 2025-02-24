import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'homepage.dart';
import 'menu.dart';
import 'profile.dart';
import 'package:ionicons/ionicons.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});
  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;
  Color iconC = Color.fromRGBO(255, 179, 0, 1);
  Color active = Color.fromRGBO(109, 121, 134, 1);
  static const List<Widget> _pages = <Widget>[
    Homepage(),
    Menu(),
    Profile(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _pages.elementAt(_selectedIndex)),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 2.0),
        child: GNav(
          //tabBackgroundColor: active,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOutQuint,
          tabActiveBorder: Border.all(color: Colors.grey, width: 1),
          gap: 3,
          //rippleColor: Colors.grey,
          haptic: true,
          tabs: const [
            GButton(
              icon: Ionicons.home_outline,
              iconSize: 20,
              textStyle: TextStyle(fontSize: 16),
              iconActiveColor: Color.fromRGBO(255, 179, 0, 1),
              text: "home",
            ),
            GButton(
              icon: LucideIcons.utensilsCrossed,
              text: "menu",
              textStyle: TextStyle(fontSize: 16),
              iconSize: 20,
              iconActiveColor: Color.fromRGBO(255, 179, 0, 1),
            ),
            GButton(
              icon: Ionicons.person_sharp,
              text: "profile",
              iconSize: 20,
              textStyle: TextStyle(fontSize: 16),
              iconActiveColor: Color.fromRGBO(255, 179, 0, 1),
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
    );
  }
}
