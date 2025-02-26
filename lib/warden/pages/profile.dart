import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:minipro/authentication/loginpage.dart';
import 'package:minipro/student/components/custom_route.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyProfile extends StatelessWidget {
  const MyProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
          child: ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                saveLoginState(false);
                Navigator.pushReplacement(
                  context,
                  myRoute(
                    LoginPage(),
                  ),
                );
              },
              child: Text("Logout")),
        ));
  }

  Future<void> saveLoginState(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }
}
