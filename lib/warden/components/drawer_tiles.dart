import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:minipro/authentication/loginpage.dart';
import 'package:minipro/student/components/custom_route.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../pages/settingspage.dart';



class DrawerTiles extends StatelessWidget {
  

  const DrawerTiles({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title:Text("settings",style:GoogleFonts.mooli ( fontSize: 18.0)),
            
            leading: Icon(Ionicons.settings_outline),
            onTap: () {
              Navigator.pop(
                context
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(),
                  ),
                );
              
            },
        
              ),
               ListTile(
          title:Text("logout",style:GoogleFonts.mooli ( fontSize: 18.0)),
           onTap:  () {
                FirebaseAuth.instance.signOut();
                saveLoginState(false);
                Navigator.pushReplacement(
                  context,
                  myRoute(
                    LoginPage(),
                  ),
                );
              },
            leading: Icon(Ionicons.log_out_outline),
         )
       ]
     );
  }

  Future<void> saveLoginState(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }
}

        