import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:minipro/student/pages/homepage.dart';
import 'package:minipro/student/pages/menu.dart';
import 'package:minipro/student/pages/profile.dart';
import 'package:ionicons/ionicons.dart';

class MainNavigator extends StatefulWidget {
  final int pageno;
  const MainNavigator({
    super.key,
    this.pageno = 0,
  });
  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;
  Color iconC = Color.fromRGBO(255, 179, 0, 1);
  Color active = Color.fromRGBO(109, 121, 134, 1);
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  static const List<Widget> _pages = <Widget>[
    Homepage(),
    Menu(),
    Profile(),
  ];
  Map<String, dynamic>? userData;
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.pageno;
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      // Handle connectivity changes
      if (results.isNotEmpty) {
        ConnectivityResult result = results.first; // Take the first result
        print("Connectivity changed: $result");
      }
    });
    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      checkNetworkStatus();
    });*/
  }

  @override
  void dispose() {
    try {
      _connectivitySubscription.cancel();
    } catch (e) {
      debugPrint("Error canceling subscription: $e");
    }
    super.dispose();
  }

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

  /*void checkNetworkStatus() {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    void networkSnackBar(ScaffoldMessengerState scaffoldMessenger) {
      SnackBar(
        behavior: SnackBarBehavior.fixed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        content: Text(
          "No Internet Connection..",
          style: GoogleFonts.inter(),
        ),
        duration: Duration.zero,
      );
    }

    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      if (result.contains(ConnectivityResult.none)) {
        print(" not connected");
        networkSnackBar(scaffoldMessenger);
      }
    });
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      if (result.contains(ConnectivityResult.none)) {
        print("not connected");
        networkSnackBar(scaffoldMessenger);
      } else {
        print(" connected");
        scaffoldMessenger
            .hideCurrentSnackBar(); // Hide when network is restored
      }
    });
  }*/
}
