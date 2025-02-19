import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'HomePage.dart';
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
  static const List<Widget> _pages = <Widget>[
    Homepage(),
    Menu(),
    Profile(),
  ];
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Center(child: _pages.elementAt(_selectedIndex)),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(2.0),
          child: GNav(
            //activeColor: Colors.deepPurple,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOutQuint,
            tabActiveBorder: Border.all(color: Colors.grey, width: 1),
            gap: 8,
            //rippleColor: Colors.grey,
            haptic: true,
            tabs: const [
              GButton(
                icon: Ionicons.home_outline,
                iconActiveColor: Color.fromRGBO(255, 179, 0, 1),
                text: "home",
              ),
              GButton(
                icon: LucideIcons.utensilsCrossed,
                text: "menu",
                iconActiveColor: Color.fromRGBO(255, 179, 0, 1),
              ),
              GButton(
                icon: Ionicons.person_sharp,
                text: "profile",
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
      ),
    );
  }
}
